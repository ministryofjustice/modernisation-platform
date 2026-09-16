#!/bin/bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_SCRIPT="$SCRIPT_DIR/config.txt"

# shellcheck source=./config.txt
source "$CONFIG_SCRIPT"

set_credentials_based_on_workspace() {
    local workspace="$1"

    case "$workspace" in
        development)
            DEVELOPMENT_CREDENTIALS
            ;;
        test)
            TEST_CREDENTIALS
            ;;
        preproduction)
            PREPRODUCTION_CREDENTIALS
            ;;
        production)
            PRODUCTION_CREDENTIALS
            ;;
        *)
            echo "Invalid workspace specified: $workspace. Skipping." >&2
            return 1
            ;;
    esac
}

ask_for_confirmation() {
    local response

    read -r -p "Do you want to delete the Terraform resources in directory $(pwd)? (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

part_1() {
    local workspace
    local full_workspace_name
    local terraform_directory

    echo "Part 1: Managing resources for the MP repository"
    echo "Loading configurations and AWS credentials..."

    if ! declare -F MP_CREDENTIALS >/dev/null; then
        echo "MP_CREDENTIALS is not defined in $CONFIG_SCRIPT" >&2
        exit 1
    fi

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

    terraform_directory="$USER_MP_DIR/terraform/environments/$APPLICATION_NAME"

    if [[ ! -d "$terraform_directory" ]]; then
        echo "Terraform directory does not exist: $terraform_directory" >&2
        exit 1
    fi

    echo "Changing to Terraform directory: $terraform_directory"
    cd -- "$terraform_directory"

    echo "Initializing Terraform..."
    terraform init

    for workspace in "${WORKSPACES[@]}"; do
        full_workspace_name="$APPLICATION_NAME-$workspace"

        echo "----------------------------------------------------------------"
        echo "Handling Terraform operations for workspace: $full_workspace_name"
        echo "Selecting Terraform workspace: $full_workspace_name"

        if terraform workspace select "$full_workspace_name"; then
            echo "Workspace $full_workspace_name selected."
            echo "WARNING: You are about to destroy all resources in workspace $full_workspace_name."

            if ask_for_confirmation; then
                echo "Destroying resources in workspace $full_workspace_name..."
                terraform destroy -auto-approve
            else
                echo "Destruction cancelled for workspace $full_workspace_name."
            fi
        else
            echo "Workspace $full_workspace_name does not exist. Skipping..."
        fi

        echo "----------------------------------------------------------------"
    done

    echo "Part 1: Terraform operations completed for the MP repository"
}

part_1
