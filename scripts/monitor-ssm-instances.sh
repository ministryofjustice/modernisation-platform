#!/bin/bash

#Set Values
export AWS_PAGER=""
regions="eu-west-2"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

#Create csv file
echo "Account ID,Account Name, Instance ID,Instance Name,SSM Status" > ssm-managed-instances.csv

#Assume Role Function
getAssumeRoleCfg() {
    account_id=$1
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/ModernisationPlatformAccess" --role-session-name "test" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

for account_id in $(jq -r '.account_ids | to_entries[] | "\(.value)"' <<< $ENVIRONMENT_MANAGEMENT); do
    echo "account: $account_id"
    getAssumeRoleCfg "$account_id"
    for region in $regions; do
        #Set Values
        AWS_REGION=$region
        account_name=$(jq -r ".account_ids | to_entries[] | select(.value==\"$account_id\").key")
        # account_id=$(aws sts get-caller-identity --query Account --output text)

        #Check for SSM managed instances
        echo "Searching for SSM managed instances in $account_name $region"
        for instance in $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
        do
            instance_name=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value]' --output text)
            managed=$(aws ssm describe-instance-information  --filters "Key=InstanceIds,Values=$instance" --query 'InstanceInformationList[*].[AssociationStatus]' --output text)
            if [[ "$managed" != "Success" ]]; then 
                managed="Not Managed";
            else
                managed="Managed"
            fi
            echo "$account_id,$account_name,$instance,$instance_name,$managed" >> ssm-managed-instances.csv
        done
    done
    export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
    rm credentials.json
done