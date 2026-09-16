#!/bin/bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE="$SCRIPT_DIR/config.txt"

ask_for_confirmation() {
    local workspace="$1"
    local response

    read -r -p "Do you want to delete the $APPLICATION_NAME-$workspace workspace from terraform/environments/bootstrap/*? (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# shellcheck source=./config.txt
source "$CONFIG_FILE"

if ! declare -F MP_CREDENTIALS >/dev/null; then
    echo "MP_CREDENTIALS is not defined in $CONFIG_FILE" >&2
    exit 1
fi

echo "Loading configurations and AWS credentials..."
MP_CREDENTIALS

echo "Loaded application name: $APPLICATION_NAME"
echo "Loaded workspaces: ${WORKSPACES[*]}"

if [[ -z "${AWS_ACCESS_KEY_ID:-}" ||
      -z "${AWS_SECRET_ACCESS_KEY:-}" ||
      -z "${AWS_SESSION_TOKEN:-}" ]]; then
    echo "One or more AWS credentials were not provided by $CONFIG_FILE." >&2
    exit 1
fi

directories=(
    "$USER_MP_DIR/terraform/environments/bootstrap/delegate-access"
    "$USER_MP_DIR/terraform/environments/bootstrap/secure-baselines"
    "$USER_MP_DIR/terraform/environments/bootstrap/single-sign-on"
    "$USER_MP_DIR/terraform/environments/bootstrap/member-bootstrap"
)

for workspace in "${WORKSPACES[@]}"; do
    if ! ask_for_confirmation "$workspace"; then
        echo "Workspace deletion cancelled."
        exit 0
    fi

    for directory in "${directories[@]}"; do
        if [[ ! -d "$directory" ]]; then
            echo "Terraform directory does not exist: $directory" >&2
            exit 1
        fi

        echo "Processing Terraform directory: $directory"
        cd -- "$directory"

        terraform init >/dev/null
        terraform workspace select default

        echo "Deleting Terraform workspace: $APPLICATION_NAME-$workspace"
        terraform workspace delete -force "$APPLICATION_NAME-$workspace"
    done
done
