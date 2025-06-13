#!/bin/bash
set -euo pipefail

# AWS credentials for the MP account
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

# S3 config
S3_BUCKET="modernisation-platform-route53-data"
S3_KEY="route53-inventory/route53-records.json"

# Temporary file for final JSON output
OUTPUT_FILE=$(mktemp)
echo "[]" > "$OUTPUT_FILE"

# Function to assume role
getAssumeRoleCreds() {
    local account_id=$1
    aws sts assume-role \
        --role-arn "arn:aws:iam::${account_id}:role/ModernisationPlatformAccess" \
        --role-session-name "route53-fetch-session" \
        --output json > credentials.json

    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

# Iterate over accounts from ENVIRONMENT_MANAGEMENT
for account_id in $(jq -r '.account_ids | to_entries[] | "\(.value)"' <<< $ENVIRONMENT_MANAGEMENT); do
    account_name=$(jq -r ".account_ids | to_entries[] | select(.value==\"$account_id\").key" <<< $ENVIRONMENT_MANAGEMENT)

    echo "Assuming role into $account_name"
    getAssumeRoleCreds "$account_id"

    zones=$(aws route53 list-hosted-zones --query 'HostedZones' --output json)
    zone_count=$(echo "$zones" | jq 'length')

    if [[ "$zone_count" -eq 0 ]]; then
        echo "No hosted zones found in $account_name, skipping."

        # Reset credentials
        export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
        export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
        rm -f credentials.json
        continue
    fi

    for row in $(echo "$zones" | jq -r '.[] | @base64'); do
        _jq() { echo "$row" | base64 --decode | jq -r "$1"; }

        zone_id=$(_jq '.Id' | cut -d'/' -f3)
        zone_name=$(_jq '.Name')

        echo "Fetching records for zone"
        records=$(aws route53 list-resource-record-sets \
            --hosted-zone-id "$zone_id" --output json)

        zone_data=$(jq -n \
            --arg account_id "$account_id" \
            --arg account_name "$account_name" \
            --arg zone_id "$zone_id" \
            --arg zone_name "$zone_name" \
            --argjson records "$records" \
            '{
                account_id: $account_id,
                account_name: $account_name,
                zone_id: $zone_id,
                zone_name: $zone_name,
                records: $records.ResourceRecordSets
            }')

        jq --argjson zone "$zone_data" '. += [$zone]' "$OUTPUT_FILE" > tmp.$$.json && mv tmp.$$.json "$OUTPUT_FILE"
    done

    # Reset to root credentials
    export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
    rm -f credentials.json

    echo "Completed $account_name"
done

# --- Upload to S3 from core-security account ---

# Get core-security-production account ID
CORE_SECURITY_ACCOUNT_ID=$(jq -r '.account_ids["core-security-production"]' <<< "$ENVIRONMENT_MANAGEMENT")

echo "Assuming role into core-security-production account for S3 upload"
getAssumeRoleCreds "$CORE_SECURITY_ACCOUNT_ID"

# Upload the result to S3
echo "Uploading to S3 in core-security-production account"
aws s3 cp "$OUTPUT_FILE" "s3://${S3_BUCKET}/${S3_KEY}"
echo "Upload successful."

# Reset credentials to root
export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN

# Clean up
rm -f "$OUTPUT_FILE"
rm -f credentials.json
