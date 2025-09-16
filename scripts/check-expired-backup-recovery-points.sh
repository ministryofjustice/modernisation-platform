#!/bin/bash

# Set values
export AWS_PAGER=""
regions="eu-west-2"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

ROLE_NAME="ModernisationPlatformAccess"

# Assume Role Function
getAssumeRoleCfg() {
    account_id=$1
    echo "Assuming role for account: $account_id"
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" --role-session-name "check-expired-recovery-points" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

# Main logic
for account_id in $(jq -r '.account_ids | to_entries[] | "\(.value)"' <<< "$ENVIRONMENT_MANAGEMENT"); do
    getAssumeRoleCfg "$account_id"

    for region in $regions; do
        AWS_REGION=$region
        account_name=$(jq -r ".account_ids | to_entries[] | select(.value==\"$account_id\").key" <<< "$ENVIRONMENT_MANAGEMENT")

        #### Check for Backup Recovery Points with Expired Status ####
        total=0
        vault=everything
        for arn in $(aws backup list-recovery-points-by-backup-vault \
            --backup-vault-name "$vault" \
            --query 'RecoveryPoints[?Status==`EXPIRED`].RecoveryPointArn' \
            --output text); do
                total=$((total+1))
        done
        echo "$account_name has $total expired recovery points in AWS Backup vault $vault""
    done

    # Reset credentials after each account
    export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
    rm credentials.json
done