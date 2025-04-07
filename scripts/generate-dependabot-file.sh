#!/usr/bin/env bash
set -euo pipefail

dependabot_file=".github/dependabot.yml"

echo "Scanning for Terraform files..."
# Find all directories containing .tf files, excluding .terraform
tf_dirs=$(find . -type f -name "*.tf" ! -path "*/.terraform/*" -exec dirname {} \; | sed 's|^\./||' | sort -u)

# Find all directories containing go.mod files, excluding .terraform
gomod_dirs=$(find . -type f -name "go.mod" ! -path "*/.terraform/*" -exec dirname {} \; | sed 's|^\./||' | sort -u)

echo "Writing dependabot.yml file"

cat > "$dependabot_file" << EOL
# This file is auto-generated, do not manually amend.
# https://github.com/ministryofjustice/modernisation-platform/blob/main/scripts/generate-dependabot-file.sh

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

# Add Terraform ecosystem entries (dynamically only for top-level directories containing .tf files)
if [[ -n "$tf_dirs" ]]; then
  echo "Generating Terraform ecosystem entry..."
  echo "  - package-ecosystem: \"terraform\"" >> "$dependabot_file"
  echo "    directories:" >> "$dependabot_file"

  # Extract only top-level directories and ensure we don't add duplicates
  echo "$tf_dirs" | awk -F/ '{print $1}' | sort -u | while IFS= read -r dir; do
    echo "      - \"$dir/**/*\"" >> "$dependabot_file"
  done
  
  echo "    schedule:" >> "$dependabot_file"
  echo "      interval: \"daily\"" >> "$dependabot_file"
  echo "    ignore:" >> "$dependabot_file"
  echo "      - dependency-name: \"integrations/github\"" >> "$dependabot_file"
fi

# Add Go module ecosystem entries (dynamically only for top-level directories containing go.mod)
if [[ -n "$gomod_dirs" ]]; then
  echo "Generating Go module ecosystem entry..."
  echo "  - package-ecosystem: \"gomod\"" >> "$dependabot_file"
  echo "    directories:" >> "$dependabot_file"

  # Extract only top-level directories and ensure we don't add duplicates
  echo "$gomod_dirs" | awk -F/ '{print $1}' | sort -u | while IFS= read -r dir; do
    echo "      - \"$dir/**/*\"" >> "$dependabot_file"
  done

  echo "    schedule:" >> "$dependabot_file"
  echo "      interval: \"daily\"" >> "$dependabot_file"
  echo "    groups:" >> "$dependabot_file"
  echo "      gomod-dependencies:" >> "$dependabot_file"
  echo "        patterns:" >> "$dependabot_file"
  echo "          - \"*\"" >> "$dependabot_file"
fi

echo "dependabot.yml has been successfully generated."
