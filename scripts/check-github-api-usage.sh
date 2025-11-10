#!/bin/bash

set -o pipefail

# This script checks the remaining API usage remaining for the authenticated GITHUB APP.
# If the remaining amount is less than the threshold (defined in RATE_LIMIT_THRESHOLD) then the script forces an exit.
# Requires $GH_TOKEN taken as output from the GH App session creation.

# Declare the two main vars of the check as integers:
declare -i REMAINING_INT
declare -i RATE_THRESHOLD_INT

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

# Set to ensure these vars are integers.
REMAINING_INT=${REMAINING:-0}
RATE_THRESHOLD_INT=${RATE_THRESHOLD:-0}

if [ "$REMAINING" -lt "$RATE_THRESHOLD" ]; then
echo "❌ Rate usage at threshold ($RATE_THRESHOLD_INT => $REMAINING_INT). Exiting."
exit 1
else
echo "✅ Rate usage within threshold ($RATE_THRESHOLD_INT < $REMAINING_INT)."
fi