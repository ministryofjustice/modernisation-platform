#!/bin/bash

# Set Values
export AWS_PAGER=""
regions="eu-west-2"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

# Create csv file
echo "Account ID,Account Name,Trigger Count" > unauthorized-api-calls.csv

# Assume Role Function
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
        # Set Values
        AWS_REGION=$region
        account_name=$(jq -r ".account_ids | to_entries[] | select(.value==\"$account_id\").key" <<< $ENVIRONMENT_MANAGEMENT)

        # Check for unauthorised-api-calls cloudwatch alarm triggers
        echo "Searching for unauthorised-api-calls alarm triggers in $account_name $region"

        count=$(aws cloudwatch describe-alarm-history \
                --alarm-name "unauthorised-api-calls" \
                --start-date $(date --date='7 days ago' -u "+%Y-%m-%dT%H:%M:%SZ") \
                --end-date $(date -u "+%Y-%m-%dT%H:%M:%SZ") \
                --query "AlarmHistoryItems[?HistorySummary=='Alarm updated from OK to ALARM'].Timestamp" \
                --output text | wc -l)

        echo "The alarm transitioned from OK to ALARM $count times in the last 7 days."
        echo "$account_id,$account_name,$count" >> unauthorized-api-calls.csv

        export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
        export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
        rm credentials.json
    done
done