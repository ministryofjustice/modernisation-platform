#!/usr/bin/env bash
set -euo pipefail

export AWS_PAGER=""
regions="eu-west-1 eu-west-2 eu-west-3 eu-central-1 us-east-1"

ROOT_AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
ROOT_AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
ROOT_AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN:-}

ROLE_NAME="ModernisationPlatformAccess" 

: "${ENVIRONMENT_MANAGEMENT:?Set ENVIRONMENT_MANAGEMENT (JSON with account_ids)}"

getAssumeRoleCfg() {
  local account_id=$1
  local resp
  resp=$(aws sts assume-role \
      --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" \
      --role-session-name "ssm-doc-block-public-check" \
      --output json)
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN
  AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<<"$resp")
  AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<<"$resp")
  AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<<"$resp")
}

accounts=$(jq -r '.account_ids | to_entries[] | "\(.key) \(.value)"' <<< "$ENVIRONMENT_MANAGEMENT")

OUTFILE="ssm-block-public-off.csv"
echo 'AccountId,AccountName,Region,SettingValue,Status,LastModifiedDate' > "$OUTFILE"

SETTING_ID="/ssm/documents/console/public-sharing-permission"

while read -r account_name account_id; do
  getAssumeRoleCfg "$account_id"

  for region in $regions; do
    raw_json=$(aws ssm get-service-setting \
      --region "$region" \
      --setting-id "$SETTING_ID" \
      --output json 2>/dev/null || true)

    if [[ -z "$raw_json" ]]; then
      continue
    fi

    setting_value=$(jq -r '.ServiceSetting.SettingValue // empty' <<<"$raw_json")
    status=$(jq -r '.ServiceSetting.Status // empty' <<<"$raw_json")
    last_mod=$(jq -r '.ServiceSetting.LastModifiedDate // empty' <<<"$raw_json")

    # Only include if public sharing is ENABLED (i.e. Block Public Sharing is OFF)
    if [[ "$setting_value" == "Enable" ]]; then
      printf '"%s","%s","%s","%s","%s","%s"\n' \
        "$account_id" "$account_name" "$region" "$setting_value" "$status" "$last_mod" \
        >> "$OUTFILE"
    fi
  done

  # Restore credentials after each account
  export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
done <<< "$accounts"

echo "Results written to $OUTFILE"
