#!/bin/bash

export AWS_PAGER=""
regions="eu-west-2"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

ROLE_NAME="ModernisationPlatformAccess"

getAssumeRoleCfg() {
    account_id=$1
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" --role-session-name "check-expired-recovery-points" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

# Loop through all accounts
accounts=$(jq -r '.account_ids | to_entries[] | "\(.key) \(.value)"' <<< "$ENVIRONMENT_MANAGEMENT")

while read -r account_name account_id; do
    getAssumeRoleCfg "$account_id"

    for region in $regions; do
        AWS_REGION=$region
        vault=everything

        expired_arns=$(aws backup list-recovery-points-by-backup-vault \
            --backup-vault-name "$vault" \
            --region "$region" \
            --query 'RecoveryPoints[?Status==`EXPIRED`].RecoveryPointArn' \
            --output text)

        if [ -z "$expired_arns" ]; then
            echo "[$account_name] No expired recovery points found for deletion in region $region."
        else
            count=$(echo "$expired_arns" | wc -w)
            echo "[$account_name] Found $count expired recovery points in region $region. Attempting deletion..."
            deleted=0
            for arn in $expired_arns; do
                # aws backup delete-recovery-point --backup-vault-name "$vault" --region "$region" --recovery-point-arn "$arn"
                deleted=$((deleted+1))
            done
            echo "[$account_name] Successfully deleted $deleted expired recovery points in region $region."
        fi
    done

    # Reset credentials after each account
    export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
    rm credentials.json
done <<< "$accounts"
