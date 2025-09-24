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
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" --role-session-name "check-expired-recovery-points" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

# Main logic
test_account_name="hmpps-esupervision-production"
test_account_id=$(jq -r ".account_ids[\"$test_account_name\"]" <<< "$ENVIRONMENT_MANAGEMENT")

getAssumeRoleCfg "$test_account_id"

for region in $regions; do
    AWS_REGION=$region
    vault=everything

    # Get list of expired recovery points
    expired_arns=$(aws backup list-recovery-points-by-backup-vault \
        --backup-vault-name "$vault" \
        --query 'RecoveryPoints[?Status==`EXPIRED`].RecoveryPointArn' \
        --output text)

    # Count number of expired recovery points
    if [ -z "$expired_arns" ]; then
        echo "[$test_account_name] No expired recovery points found for deletion in region $region."
    else
        count=$(echo "$expired_arns" | wc -w)
        echo "[$test_account_name] Found $count expired recovery points in region $region. Attempting deletion..."
        deleted=0
        for arn in $expired_arns; do
            aws backup delete-recovery-point --backup-vault-name "$vault" --recovery-point-arn "$arn"
            deleted=$((deleted+1))
        done
        echo "[$test_account_name] Successfully deleted $deleted expired recovery points in region $region."
    fi

# Reset credentials after the test account
export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
rm credentials.json
done