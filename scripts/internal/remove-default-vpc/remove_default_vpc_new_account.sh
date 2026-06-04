#!/bin/bash
regions="eu-central-1 eu-west-1 eu-west-2 us-east-1 eu-west-3"
account_id="$1"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

getAssumeRoleCfg() {
    account_id=$1
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/ModernisationPlatformAccess" --role-session-name "test" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

echo "account: $account_id"
getAssumeRoleCfg "$account_id"
for region in $regions; do
    delete_subnet_error=false
    #Skipping region due to insufficient permissions.
    if ! aws ec2 describe-vpcs --region $region &> /dev/null; then
        continue
    fi
    # Get default VPC ID
    vpc_id=$(aws ec2 describe-vpcs --region $region --filters Name=isDefault,Values=true | jq -r .Vpcs[0].VpcId)
    echo "region: $region vpc: $vpc_id"
    if [ "$vpc_id" != "null" ]; then
        echo "Deleting default VPC ($vpc_id) in region $region..."
        # Detach and delete any internet gateway associated with the VPC
        internet_gateway_id=$(aws ec2 describe-internet-gateways --region $region --filters Name=attachment.vpc-id,Values=$vpc_id | jq -r .InternetGateways[0].InternetGatewayId)
        if [ "$internet_gateway_id" != "null" ]; then
            if ! aws ec2 detach-internet-gateway --region $region --internet-gateway-id $internet_gateway_id --vpc-id $vpc_id &> /dev/null; then
                echo "Error: Failed to detach internet gateway for account $account_id. Continuing with the next account..."
                continue  # Skip to the next iteration of the loop for the next account
            fi
            aws ec2 delete-internet-gateway --region $region --internet-gateway-id $internet_gateway_id
        fi

        # Delete subnets associated with the VPC
        subnets=$(aws ec2 describe-subnets --region $region --filters Name=vpc-id,Values=$vpc_id | jq -r .Subnets[].SubnetId)
        if [ ! -z "$subnets" ]; then
            for subnet_id in $subnets; do
                if ! aws ec2 delete-subnet --region $region --subnet-id $subnet_id &> /dev/null; then
                    echo "Error deleting subnet $subnet_id in region $region. Continuing to next region."
                    delete_subnet_error=true
                    break
                fi
            done
        fi

        # Delete the VPC
        if [ "$delete_subnet_error" = false ]; then
            aws ec2 delete-vpc --region $region --vpc-id $vpc_id
        fi
    fi
done
export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
rm credentials.json