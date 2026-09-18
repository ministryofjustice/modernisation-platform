#!/bin/bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_SCRIPT="$SCRIPT_DIR/config.txt"

echo "Managing Terraform state for the MP repository"

# shellcheck source=./config.txt
source "$CONFIG_SCRIPT"

if ! declare -F MP_CREDENTIALS >/dev/null; then
    echo "MP_CREDENTIALS is not defined in $CONFIG_SCRIPT" >&2
    exit 1
fi

echo "Loading configurations and AWS credentials..."
MP_CREDENTIALS

echo "Loaded application name: $APPLICATION_NAME"
echo "Loaded workspaces: ${WORKSPACES[*]}"

# Verify that the required AWS environment variables are set.
if [[ -z "${AWS_ACCESS_KEY_ID:-}" ||
      -z "${AWS_SECRET_ACCESS_KEY:-}" ||
      -z "${AWS_SESSION_TOKEN:-}" ]]; then
    echo "One or more AWS credentials were not provided by $CONFIG_SCRIPT." >&2
    exit 1
fi

terraform_directory="$USER_MP_DIR/terraform/environments"

if [[ ! -d "$terraform_directory" ]]; then
    echo "Terraform directory does not exist: $terraform_directory" >&2
    exit 1
fi

echo "Changing to Terraform directory: $terraform_directory"
cd -- "$terraform_directory"

echo "Initializing Terraform..."
terraform init

for workspace in "${WORKSPACES[@]}"; do
    echo "Managing resources for application '$APPLICATION_NAME' in the '$workspace' environment."

    resource_to_remove="module.environments.aws_organizations_account.accounts[\"$APPLICATION_NAME-$workspace\"]"

    read -r -p "Are you sure you want to remove $resource_to_remove from the Terraform state? [y/N]: " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Removing $resource_to_remove from the Terraform state..."
        terraform state rm "$resource_to_remove"
    else
        echo "Skipping removal of $resource_to_remove."
    fi
done

echo "Terraform state management operations completed."
