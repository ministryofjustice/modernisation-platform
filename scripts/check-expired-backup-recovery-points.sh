#!/bin/bash

# Set values
export AWS_PAGER=""
regions="eu-west-2"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

ROLE_NAME="ModernisationPlatformAccess"
EXPIRED_RECOVERY_POINTS_FILE="expired-recovery-points.csv"

# Initialize the file with headers
# echo "Account Name,Expired Recovery Points Count" > $EXPIRED_RECOVERY_POINTS_FILE

# Assume Role Function
getAssumeRoleCfg() {
    account_id=$1
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" --role-session-name "check-expired-recovery-points" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

# Main logic
test_account_name="long-term-storage-production"

# Get the account ID from ENVIRONMENT_MANAGEMENT using the account name
test_account_id=$(jq -r ".account_ids[\"$test_account_name\"]" <<< "$ENVIRONMENT_MANAGEMENT")

getAssumeRoleCfg "$test_account_id"

for region in $regions; do
    AWS_REGION=$region

    #### Check for Backup Recovery Points with Expired Status ####
    total=0
    vault=everything

    # for arn in $(aws backup list-recovery-points-by-backup-vault \
    #     --backup-vault-name "$vault" \
    #     --query 'RecoveryPoints[?Status==`EXPIRED`].RecoveryPointArn' \
    #     --output text); do
    #         total=$((total+1))
    # done
    # echo "$test_account_name,$total" >> $EXPIRED_RECOVERY_POINTS_FILE

    #### Delete Expired Backup Recovery Points ####
    for arn in $(aws backup list-recovery-points-by-backup-vault \
        --backup-vault-name "$vault" \
        --query 'RecoveryPoints[?Status==`EXPIRED`].RecoveryPointArn' \
        --output text); do
            aws backup delete-recovery-point --backup-vault-name "$vault" --recovery-point-arn "$arn"
    done
done

# Reset credentials after the test account
export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
rm credentials.json
done