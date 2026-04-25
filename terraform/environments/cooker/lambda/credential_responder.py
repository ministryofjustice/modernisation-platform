import boto3
import json
import os
from datetime import datetime, timezone

iam = boto3.client("iam")
sns = boto3.client("sns")

DENY_ALL = json.dumps({
    "Version": "2012-10-17",
    "Statement": [{"Effect": "Deny", "Action": "*", "Resource": "*"}]
})

def get_username_for_key(key_id):
    paginator = iam.get_paginator("list_users")
    for page in paginator.paginate():
        for user in page["Users"]:
            keys = iam.list_access_keys(UserName=user["UserName"])["AccessKeyMetadata"]
            if any(k["AccessKeyId"] == key_id for k in keys):
                return user["UserName"]
    return None

def handler(event, context):
    detail   = event.get("detail", {})
    entities = detail.get("affectedEntities", [])

    for entity in entities:
        key_id   = entity["entityValue"]
        username = get_username_for_key(key_id)

        if not username:
            print(f"Could not find a user for key {key_id} — may already be deleted")
            continue

        # 1. Disable the exposed key
        iam.update_access_key(
            UserName=username,
            AccessKeyId=key_id,
            Status="Inactive"
        )
        print(f"Disabled key {key_id} for user {username}")

        # 2. Attach deny-all quarantine policy
        iam.put_user_policy(
            UserName=username,
            PolicyName="EmergencyQuarantine",
            PolicyDocument=DENY_ALL
        )
        print(f"Quarantine policy applied to {username}")

        # 3. Publish to SNS → PagerDuty
        sns.publish(
            TopicArn=os.environ["CREDENTIAL_ALERT_SNS_ARN"],
            Subject="ALARM: IAM_CREDENTIAL_EXPOSED",
            Message=json.dumps({
                "AlarmName":        "IAM_CREDENTIAL_EXPOSED",
                "AlarmDescription": f"Exposed IAM key {key_id} detected for user {username}",
                "AWSAccountId":     event.get("account", "unknown"),
                "NewStateValue":    "ALARM",
                "NewStateReason":   f"Exposed key {key_id} for user {username}. Key disabled and quarantine policy applied automatically.",
                "NewStateReasonData": "",
                "OldStateValue":    "OK",
                "StateChangeTime":  datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.000Z"),
                "Region":           "EU (London)",
                "Trigger": {
                    "MetricName": "IAM_CREDENTIAL_EXPOSED",
                    "Namespace":  "Security",
                    "Dimensions": []
                }
            })
        )
        print(f"SNS alert published for {key_id}")