#!/usr/bin/env bash
set -euo pipefail

dependabot_file=".github/dependabot.yml"

# Dependabot cooldown configuration (applies to version updates only)
# Docs: https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference#cooldown-
dependabot_cooldown_default_days="${DEPENDABOT_COOLDOWN_DEFAULT_DAYS:-7}"

if ! [[ "$dependabot_cooldown_default_days" =~ ^[0-9]+$ ]]; then
  echo "ERROR: DEPENDABOT_COOLDOWN_DEFAULT_DAYS must be an integer (days), got: '$dependabot_cooldown_default_days'" >&2
  exit 1
fi

if (( dependabot_cooldown_default_days < 1 || dependabot_cooldown_default_days > 90 )); then
  echo "ERROR: DEPENDABOT_COOLDOWN_DEFAULT_DAYS must be between 1 and 90 (inclusive), got: '$dependabot_cooldown_default_days'" >&2
  exit 1
fi

# Clear the dependabot file
> "$dependabot_file"

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
  - package-ecosystem: "devcontainers"
    directory: "/"
    schedule:
      interval: "daily"
    commit-message:
      prefix: ":dependabot: devcontainers"
      include: "scope"
    cooldown:
      default-days: ${dependabot_cooldown_default_days}
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
    cooldown:
      default-days: ${dependabot_cooldown_default_days}
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
  echo "    cooldown:" >> "$dependabot_file"
  echo "      default-days: ${dependabot_cooldown_default_days}" >> "$dependabot_file"
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
  echo "    cooldown:" >> "$dependabot_file"
  echo "      default-days: ${dependabot_cooldown_default_days}" >> "$dependabot_file"
  echo "    groups:" >> "$dependabot_file"
  echo "      gomod-dependencies:" >> "$dependabot_file"
  echo "        patterns:" >> "$dependabot_file"
  echo "          - \"*\"" >> "$dependabot_file"
fi

echo "dependabot.yml has been successfully generated."
