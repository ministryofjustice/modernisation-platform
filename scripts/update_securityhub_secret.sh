#!/bin/bash
set +x

APP_NAME=$1
SECRET_NAME="securityhub_slack_webhooks"
REGION="eu-west-2"
JSON_FILE="./environments/${APP_NAME}.json"

if [[ ! -f "$JSON_FILE" ]]; then
  echo "File $JSON_FILE not found."
  exit 1
fi

# Extract slack-channel tag
SLACK_CHANNEL=$(jq -r '.tags["securityhub-slack-channel"] // empty' "$JSON_FILE")
if [[ -z "$SLACK_CHANNEL" ]]; then
  echo "No tag 'slack-channel' in ${APP_NAME}.json."
  exit 0
fi

# Decrypt the webhook URL
SLACK_WEBHOOK_URL=$(echo "$ENCRYPTED_SLACK_WEBHOOK_URL" | base64 --decode | gpg --decrypt --quiet --batch --passphrase "$PASSPHRASE")

# Get current secret
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --region "$REGION" --query SecretString --output text)

# Check if the key exists in secret
EXISTING_VALUE=$(echo "$SECRET_JSON" | jq -r --arg key "$SLACK_CHANNEL" '.[$key] // empty')

# Update or add the key-value pair
UPDATED_JSON=$(echo "$SECRET_JSON" | jq --arg k "$SLACK_CHANNEL" --arg v "$SLACK_WEBHOOK_URL" '.[$k] = $v')

# Put updated secret back
aws secretsmanager update-secret --secret-id "$SECRET_NAME" --region "$REGION" --secret-string "$UPDATED_JSON" > /dev/null

if [[ -n "$EXISTING_VALUE" ]]; then
  echo "Slack channel '$SLACK_CHANNEL' webhook updated in secret."
else
  echo "Slack channel '$SLACK_CHANNEL' webhook added to secret."
fi