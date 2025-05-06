import os
import json
import logging
import boto3
import ipaddress

# ─────────────────────────────────────────────────────────────────────────────
# Configuration from environment
AWS_RESERVED_IPS = int(os.getenv('AWS_RESERVED_IPS', '5'))
ASSUME_ROLE_NAME = os.getenv('ASSUME_ROLE_NAME', 'IPUsageMetricsReadRole')
METRIC_NAMESPACE = os.getenv('METRIC_NAMESPACE', 'Custom/SubnetInfo')
TARGET_ACCOUNTS  = [acct.strip() for acct in os.getenv('TARGET_ACCOUNTS', '').split(',') if acct.strip()]

# Setup root logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ─────────────────────────────────────────────────────────────────────────────
def assume_role_session(account_id: str, role_name: str) -> boto3.Session:
    """
    Assume the given IAM role in the target account and return a boto3.Session
    with those temporary credentials.
    """
    sts = boto3.client('sts')
    role_arn = f"arn:aws:iam::{account_id}:role/{role_name}"
    resp = sts.assume_role(
        RoleArn=role_arn,
        RoleSessionName='SubnetMetricsSession'
    )['Credentials']

    return boto3.Session(
        aws_access_key_id=resp['AccessKeyId'],
        aws_secret_access_key=resp['SecretAccessKey'],
        aws_session_token=resp['SessionToken']
    )


def fetch_all_subnets(ec2_client) -> list:
    """
    Retrieve all subnets, handling pagination.
    """
    paginator = ec2_client.get_paginator('describe_subnets')
    page_iterator = paginator.paginate()
    subnets = []
    for page in page_iterator:
        subnets.extend(page.get('Subnets', []))
    return subnets


def get_tag_value(tags: list, key: str, default: str = 'N/A') -> str:
    return next((t['Value'] for t in tags or [] if t['Key'] == key), default)


def compute_subnet_metrics(subnet: dict) -> tuple[int, int, int, float]:
    """
    Calculate total, available, used IPs and utilization percentage.
    """
    total = ipaddress.IPv4Network(subnet['CidrBlock']).num_addresses - AWS_RESERVED_IPS
    avail = subnet.get('AvailableIpAddressCount')
    if avail is None:
        raise KeyError(f"AvailableIpAddressCount missing for {subnet['SubnetId']}")
    used = max(0, total - avail)
    pct = (used / total * 100) if total > 0 else 0.0
    return total, avail, used, pct


def build_dimensions(subnet: dict, region: str, account_id: str) -> list[dict]:
    base_dims = {
        'SubnetId': subnet['SubnetId'],
        'SubnetName': get_tag_value(subnet.get('Tags'), 'Name'),
        'VpcId': subnet['VpcId'],
        'AvailabilityZone': subnet['AvailabilityZone'],
        'Region': region,
        'AccountId': account_id
    }
    return [{'Name': k, 'Value': v} for k, v in base_dims.items()]


def publish_metrics(cw_client, dims: list, metrics: list[tuple]):
    metric_data = [
        {
            'MetricName': name,
            'Dimensions': dims,
            'Value': value,
            'Unit': unit
        }
        for name, value, unit in metrics
    ]
    cw_client.put_metric_data(Namespace=METRIC_NAMESPACE, MetricData=metric_data)


def process_account(account_id: str, region: str):
    """
    For a single account: assume role, fetch subnets, compute and publish metrics.
    """
    session = assume_role_session(account_id, ASSUME_ROLE_NAME)
    ec2 = session.client('ec2', region_name=region)
    cw = session.client('cloudwatch', region_name=region)

    subnets = fetch_all_subnets(ec2)
    logger.info(f"[{account_id}] Found {len(subnets)} subnets in {region}")

    processed = 0
    for s in subnets:
        try:
            total, avail, used, pct = compute_subnet_metrics(s)
            dims = build_dimensions(s, region, account_id)
            metrics = [
                ('UsedIPs', used, 'Count'),
                ('AvailableIPs', avail, 'Count'),
                ('TotalIPs', total, 'Count'),
                ('IPUtilizationPercentage', pct, 'Percent')
            ]
            publish_metrics(cw, dims, metrics)

            logger.info(
                f"{s['SubnetId']} ({s['AvailabilityZone']}, {s['VpcId']}) "
                f"{s['CidrBlock']} [{get_tag_value(s.get('Tags'), 'Name')}]: "
                f"Util={pct:.1f}% ({used}/{total}, {avail} avail)"
            )
            processed += 1
        except KeyError as e:
            logger.warning(f"[{account_id}] Skipping subnet: {e}")
        except Exception:
            logger.exception(f"[{account_id}] Error processing subnet {s['SubnetId']}")

    logger.info(f"[{account_id}] Published metrics for {processed}/{len(subnets)} subnets")


def lambda_handler(event, context):
    region = os.getenv('AWS_REGION', 'us-east-1')
    logger.info(f"Starting subnet scan across accounts: {TARGET_ACCOUNTS} in {region}")

    for account in TARGET_ACCOUNTS:
        try:
            process_account(account, region)
        except Exception:
            logger.exception(f"Failed to process account {account}")

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Subnet metrics scan complete.'})
    }