#!/bin/bash
set -euo pipefail

ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

getAssumeRoleCfg() {
    account_id=$1

    aws sts assume-role \
        --role-arn "arn:aws:iam::${account_id}:role/ModernisationPlatformAccess" \
        --role-session-name "delete-config-buckets" \
        --output json > credentials.json

    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

empty_and_delete_bucket() {
    bucket=$1

    echo "Processing bucket: $bucket"

    # Delete all objects (non-versioned)
    aws s3 rm "s3://$bucket" --recursive || true

    # Handle versioned objects
    while true; do
        versions_json=$(aws s3api list-object-versions \
            --bucket "$bucket" \
            --output json)

        versions_count=$(echo "$versions_json" | jq '.Versions | length')
        markers_count=$(echo "$versions_json" | jq '.DeleteMarkers | length')

        if [ "$versions_count" -eq 0 ] && [ "$markers_count" -eq 0 ]; then
            break
        fi

        echo "$versions_json" | jq -r '
            (.Versions[]? | [.Key, .VersionId]),
            (.DeleteMarkers[]? | [.Key, .VersionId])
            | @tsv
        ' | while IFS=$'\t' read -r key version_id; do

            aws s3api delete-object \
                --bucket "$bucket" \
                --key "$key" \
                --version-id "$version_id"
        done
    done

    echo "Empty bucket done: $bucket"

    aws s3api delete-bucket --bucket "$bucket"
    echo "Deleted bucket: $bucket"
}

# -----------------------------
# SINGLE ACCOUNT MODE
# -----------------------------

ACCOUNT_ID=$1

echo "Running for account: $ACCOUNT_ID"

getAssumeRoleCfg "$ACCOUNT_ID"

buckets=$(aws s3api list-buckets \
    --query "Buckets[?starts_with(Name, 'config-')].Name" \
    --output text)

if [ -z "$buckets" ]; then
    echo "No config-* buckets found"
else
    for bucket in $buckets; do
        empty_and_delete_bucket "$bucket"
    done
fi

# restore root creds
export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN

rm -f credentials.json