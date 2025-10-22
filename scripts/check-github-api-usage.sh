#!/bin/bash

set -o pipefail

# This script checks the remaining API usage remaining for the github APP as authenticated in the $APP_TOKEN

# If the used amount is greater than the threshold then the script forces an exit.

# Requires GH_TOKEN taken as output from the GH App session creation.

echo "Fetching API rate limit for App installation..."
RESPONSE=$(curl -s \
-H "Authorization: Bearer $GH_TOKEN" \
-H "Accept: application/vnd.github+json" \
https://api.github.com/rate_limit)
echo "$RESPONSE" | jq '.resources.core'

RESET_EPOCH=$(echo "$RESPONSE" | jq '.resources.core.reset')
RESET_UTC=$(date -u -d @"$RESET_EPOCH" '+%Y-%m-%d %H:%M:%S UTC')
echo "Rate limit resets at: $RESET_UTC"

USED=$(echo "$RESPONSE" | jq '.resources.core.used')
REMAINING=$(echo "$RESPONSE" | jq '.resources.core.remaining')

echo "Rate used: $USED"
echo "Rate remaining: $REMAINING"

if [ "$REMAINING" -lt "$RATE_THRESHOLD" ]; then
echo "❌ Rate usage above threshold ($REMAINING > $RATE_THRESHOLD). Exiting."
exit 1
else
echo "✅ Rate usage within threshold ($REMAINING ≤ $RATE_THRESHOLD)."
fi