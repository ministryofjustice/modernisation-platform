#!/bin/bash

# This script allows the user to generate an authenticated github using the modernisation-platform github app.
# The user must already be authenticated & authorised using the MP Engineer SSO role.
# The script also makes use of the github command line utility (gh). This can be installed via homebrew (brew install gh).

# Configuration
APP_ID="2013696" # The id of the Modernisation Platform github app
SECRET_NAME="modernisation_platform_github_app_private_key"  # The AWS secret with the App's Private Key
ORG_NAME="ministryofjustice" 

# Get private key from AWS Secrets Manager
PRIVATE_KEY=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --query SecretString \
    --output text)

# 1. Generate JWT
# Get current time
NOW=$(date +%s)
EXP=$((NOW + 600))  # 10 minutes from now

# Create JWT header and payload
HEADER='{"alg":"RS256","typ":"JWT"}'
PAYLOAD="{\"iat\":${NOW},\"exp\":${EXP},\"iss\":\"${APP_ID}\"}"

# Base64 encode (URL-safe)
HEADER_B64=$(echo -n "$HEADER" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
PAYLOAD_B64=$(echo -n "$PAYLOAD" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Create signature (use private key from variable)
SIGNATURE=$(echo -n "${HEADER_B64}.${PAYLOAD_B64}" | \
    openssl dgst -sha256 -sign <(echo "$PRIVATE_KEY") | \
    openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

JWT=$(echo "${HEADER_B64}.${PAYLOAD_B64}.${SIGNATURE}" | tr -d '\n\r ')

# 2. Get installation ID for the organization
INSTALLATIONS_RESPONSE=$(curl -s -X GET \
    -H "Authorization: Bearer ${JWT}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/app/installations")

INSTALLATION_ID=$(echo "$INSTALLATIONS_RESPONSE" | jq -r ".[] | select(.account.login==\"${ORG_NAME}\") | .id")

if [ -z "$INSTALLATION_ID" ] || [ "$INSTALLATION_ID" = "null" ]; then
    echo "Error: Could not find installation ID for organization ${ORG_NAME}"
    exit 1
fi

echo "Found installation ID: ${INSTALLATION_ID}"

# 3. Get installation access token
TOKEN_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer ${JWT}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/app/installations/${INSTALLATION_ID}/access_tokens")

INSTALLATION_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.token' | tr -d '\n\r ')

echo "Token: $INSTALLATION_TOKEN"

# Test the session
gh auth status