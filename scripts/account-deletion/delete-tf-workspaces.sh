#!/bin/bash
set -e

<<<<<<< Updated upstream
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE="$SCRIPT_DIR/config.txt"
=======
# Define the path to the credentials and configuration file
# shellcheck disable=SC1091
CONFIG_FILE="config.txt"
>>>>>>> Stashed changes

ask_for_confirmation() {
    local workspace="$1"
    local response

    read -r -p "Do you want to delete the $APPLICATION_NAME-$workspace workspace from terraform/environments/bootstrap/*? (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

<<<<<<< Updated upstream
# shellcheck source=./config.txt
source "$CONFIG_FILE"
=======
# Function to load configurations and AWS credentials from config.sh
load_configurations_and_credentials() {
    echo "Loading configurations and AWS credentials..."
    # shellcheck disable=SC1091
    source "$CONFIG_FILE"
    
    # Call the MP_CREDENTIALS function to load credentials
    MP_CREDENTIALS
    
    # Debugging: Echo the loaded configurations and AWS credentials to verify
    echo "Loaded application name: $APPLICATION_NAME"
    echo "Loaded workspaces: ${WORKSPACES[*]}"
    echo "Debugging - AWS_ACCESS_KEY_ID is set to: $AWS_ACCESS_KEY_ID"
    echo "Debugging - AWS_SECRET_ACCESS_KEY is set to: $AWS_SECRET_ACCESS_KEY"
    echo "Debugging - AWS_SESSION_TOKEN is set to: $AWS_SESSION_TOKEN"
}
>>>>>>> Stashed changes

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
