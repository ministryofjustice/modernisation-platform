#!/bin/bash

set -euo pipefail

dependabot_file=".github/dependabot.yml"

# Clear the dependabot file
> "$dependabot_file"

# Get a list of unique Terraform directories, excluding `.terraform`
all_tf_folders=$(find . -type f -name '*.tf' ! -path "*/.terraform/*" | sed 's#/[^/]*$##' | sed 's|^\./||' | sort -u)

# Get a list of unique Go module directories, excluding `.terraform`
all_env_test_folders=$(find . -type f -name 'go.mod' ! -path "*/.terraform/*" | sed 's#/[^/]*$##' | sed 's|^\./||' | sort -u)

echo
echo "All Terraform folders:"
printf '%s\n' "$all_tf_folders"
echo
echo "All Go module folders:"
printf '%s\n' "$all_env_test_folders"

echo "Writing dependabot.yml file"
cat > "$dependabot_file" << EOL
# This file is auto-generated, do not manually amend.
# https://github.com/ministryofjustice/modernisation-platform/blob/main/scripts/generate-dependabot.sh

version: 2

updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
    groups:
      action-dependencies:
        patterns:
          - "*"
EOL

# Add Terraform ecosystem entries
if [[ -n "$all_tf_folders" ]]; then
  echo "Generating Terraform ecosystem entry..."
  echo "  - package-ecosystem: \"terraform\"" >> "$dependabot_file"
  echo "    directories:" >> "$dependabot_file"
  while IFS= read -r folder; do
    echo "      - \"/$folder\"" >> "$dependabot_file"
  done <<< "$all_tf_folders"
  echo "    schedule:" >> "$dependabot_file"
  echo "      interval: \"daily\"" >> "$dependabot_file"
fi

# Add Go module ecosystem entries
if [[ -n "$all_env_test_folders" ]]; then
  echo "Generating Go module ecosystem entry..."
  echo "  - package-ecosystem: \"gomod\"" >> "$dependabot_file"
  echo "    directories:" >> "$dependabot_file"
  while IFS= read -r folder; do
    echo "      - \"/$folder\"" >> "$dependabot_file"
  done <<< "$all_env_test_folders"
  echo "    schedule:" >> "$dependabot_file"
  echo "      interval: \"daily\"" >> "$dependabot_file"
fi

echo "dependabot.yml has been successfully generated."
