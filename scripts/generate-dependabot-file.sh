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

if ((dependabot_cooldown_default_days < 1 || dependabot_cooldown_default_days > 90)); then
  echo "ERROR: DEPENDABOT_COOLDOWN_DEFAULT_DAYS must be between 1 and 90 (inclusive), got: '$dependabot_cooldown_default_days'" >&2
  exit 1
fi

echo "Generating dependabot.yml..."

cat > "$dependabot_file" <<'EOF'
---
# This file is auto-generated, do not manually amend.
# scripts/generate-dependabot-file.sh

version: 2

updates:
  # Dependency management strategy:
  # ministryofjustice/modernisation-platform#8211
  #
  # Major and minor/patch version updates are grouped separately, with both
  # checked monthly to reduce routine Dependabot PR noise.
  #
  # Monthly is a compromise, not the ticket's proposed fortnightly major
  # and six-monthly minor/patch cadence.
  #
  # Dependabot alerts and security updates must be enabled separately in
  # repository/org settings; security updates do not wait for this schedule.
EOF

# Append a Dependabot ecosystem block for each set of discovered directories.
append_ecosystem() {
  local ecosystem="$1"
  local group_prefix="$2"
  shift 2

  local directories=("$@")

  if ((${#directories[@]} == 0)); then
    return
  fi

  {
    echo "  - package-ecosystem: \"$ecosystem\""
    echo "    directories:"

    for directory in "${directories[@]}"; do
      if [[ "$directory" == "." ]]; then
        echo '      - "/"'
      else
        echo "      - \"/$directory\""
      fi
    done

    echo "    schedule:"
    echo '      interval: "monthly"'
    echo "    cooldown:"
    echo "      default-days: $dependabot_cooldown_default_days"
    echo "    groups:"
    echo "      ${group_prefix}-major:"
    echo "        update-types:"
    echo '          - "major"'
    echo "      ${group_prefix}-minor-patch:"
    echo "        update-types:"
    echo '          - "minor"'
    echo '          - "patch"'
  } >> "$dependabot_file"
}

# GitHub Actions always uses the repository root.
cat >> "$dependabot_file" <<EOF

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    cooldown:
      default-days: $dependabot_cooldown_default_days
    groups:
      action-major:
        update-types:
          - "major"
      action-minor-patch:
        update-types:
          - "minor"
          - "patch"

EOF

# Bundler
mapfile -t bundler_dirs < <(
  find . \
    -type f \
    -name 'Gemfile.lock' \
    ! -path '*/.git/*' \
    -exec dirname {} \; |
    sed 's|^\./||' |
    sort -u
)

append_ecosystem "bundler" "bundler" "${bundler_dirs[@]}"

# Docker
mapfile -t docker_dirs < <(
  find . \
    -type f \
    -name 'Dockerfile' \
    ! -path '*/.git/*' \
    -exec dirname {} \; |
    sed 's|^\./||' |
    sort -u
)

append_ecosystem "docker" "docker" "${docker_dirs[@]}"

# Terraform
mapfile -t terraform_dirs < <(
  find . \
    -type f \
    -name '*.tf' \
    ! -path '*/.terraform/*' \
    ! -path '*/.git/*' \
    -exec dirname {} \; |
    sed 's|^\./||' |
    sort -u
)

append_ecosystem "terraform" "terraform" "${terraform_dirs[@]}"

# Go modules
mapfile -t gomod_dirs < <(
  find . \
    -type f \
    -name 'go.mod' \
    ! -path '*/.terraform/*' \
    ! -path '*/.git/*' \
    -exec dirname {} \; |
    sed 's|^\./||' |
    sort -u
)

append_ecosystem "gomod" "gomod" "${gomod_dirs[@]}"

# Python
mapfile -t pip_dirs < <(
  find . \
    -type f \
    \( -name 'requirements.txt' -o -name 'pyproject.toml' -o -name 'Pipfile' \) \
    ! -path '*/.git/*' \
    ! -path '*/.venv/*' \
    ! -path '*/venv/*' \
    -exec dirname {} \; |
    sed 's|^\./||' |
    sort -u
)

append_ecosystem "pip" "pip" "${pip_dirs[@]}"

# Node
mapfile -t npm_dirs < <(
  find . \
    -type f \
    -name 'package.json' \
    ! -path '*/node_modules/*' \
    ! -path '*/.git/*' \
    -exec dirname {} \; |
    sed 's|^\./||' |
    sort -u
)

append_ecosystem "npm" "npm" "${npm_dirs[@]}"

echo "✅ dependabot.yml has been generated at $dependabot_file"
