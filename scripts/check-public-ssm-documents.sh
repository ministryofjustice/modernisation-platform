#!/usr/bin/env bash

export AWS_PAGER=""
regions="eu-west-1 eu-west-2 eu-west-3 eu-central-1 us-east-1"
ROOT_AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
ROOT_AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
ROOT_AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN:-}

ROLE_NAME="ModernisationPlatformAccess" # Change if needed

# Your ENVIRONMENT_MANAGEMENT must be set in the environment as JSON.
: "${ENVIRONMENT_MANAGEMENT:?Set ENVIRONMENT_MANAGEMENT (JSON with account_ids)}"

getAssumeRoleCfg() {
    account_id=$1
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" --role-session-name "public-ssm-doc-check" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

accounts=$(jq -r '.account_ids | to_entries[] | "\(.key) \(.value)"' <<< "$ENVIRONMENT_MANAGEMENT")

while read -r account_name account_id; do
    getAssumeRoleCfg "$account_id"

    for region in $regions; do
        echo "Scanning $account_name ($account_id) in $region..."

        OUTPUT_FILE="public-ssm-documents-${account_id}-${region}.csv"
        echo 'AccountId,AccountName,Region,Name,Owner,DocumentType,ARN,Visibility' > "$OUTPUT_FILE"

        DOC_TYPES="Automation,Command,Policy,Session,ChangeCalendar,ProblemAnalysis,ApplicationConfiguration,ApplicationConfigurationSchema"

        DOCS_JSON=$(aws ssm list-documents --region "$region" \
          --filters "Key=Owner,Values=Self" "Key=DocumentType,Values=${DOC_TYPES}" \
          --query 'DocumentIdentifiers' --output json 2>/dev/null || echo '[]')

        echo "$DOCS_JSON" | jq -c '.[]' | while read -r doc; do
            NAME=$(echo "$doc" | jq -r '.Name')
            OWNER=$(echo "$doc" | jq -r '.Owner')
            TYPE=$(echo "$doc" | jq -r '.DocumentType')
            ARN=$(echo "$doc" | jq -r '.DocumentArn')

            if [[ "$OWNER" != "$account_id" ]]; then
                continue
            fi

            ACCTS=$(aws ssm describe-document-permission --region "$region" \
                      --name "$NAME" --permission-type Share \
                      --query 'AccountIds' --output text 2>/dev/null || true)

            if echo "$ACCTS" | grep -qw "all"; then
                VISIBILITY="Public"
            else
                VISIBILITY="Private"
            fi

            printf '"%s","%s","%s","%s","%s","%s","%s","%s"\n' \
              "$account_id" "$account_name" "$region" "$NAME" "$OWNER" "$TYPE" "$ARN" "$VISIBILITY" \
              >> "$OUTPUT_FILE"
        done

        echo "Results for $account_name ($account_id) in $region written to $OUTPUT_FILE"
    done

    # Reset credentials after each account
    export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
    rm -f credentials.json
done <<< "$accounts"