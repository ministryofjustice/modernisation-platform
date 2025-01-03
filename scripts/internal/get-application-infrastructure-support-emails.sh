#!/bin/bash

# Pass in the directory to be parsed, or parse the current directory
# EG. ./get-application-infrastructure-support-emails.sh ~/github.com/ministryofjustice/modernisation-platform/environments
if [ -z "$1" ]; then
    dir="."
else
    dir="$1"
fi

# Print header
printf "%-30s | %s\n" "APPLICATION" "INFRASTRUCTURE SUPPORT"
printf "%s\n" "$(printf '=%.0s' {1..80})"

# Process files
for file in "$dir"/*.json; do
    if [ -f "$file" ]; then
        app=$(jq -r '.tags.application' "$file")
        email=$(jq -r '.tags."infrastructure-support"' "$file")
        printf "%-30s | %s\n" "$app" "$email"
    fi
done
