#!/bin/bash

# Path to the configuration file
CONFIG_FILE="example-config.txt"

# Function to load and parse the configuration file
load_config() {
    while IFS= read -r line; do
        if [[ "$line" =~ ^#.*$ ]]; then
            continue # Skip comments
        fi
        if [[ "$line" =~ WORKSPACES=.* ]]; then
            WORKSPACES=($(echo "$line" | sed 's/WORKSPACES=\(.*\)/\1/' | tr -d '()' | tr -d '"' | tr " " "\n"))
        elif [[ "$line" =~ APPLICATION_NAME=.* ]]; then
            APPLICATION_NAME=$(echo "$line" | cut -d'=' -f2 | tr -d '"')
        elif [[ "$line" =~ MEMBER_ACCOUNT=.* ]]; then
            MEMBER_ACCOUNT=$(echo "$line" | cut -d'=' -f2 | tr -d '"')
        elif [[ "$line" =~ MODERNISATION_ACCOUNT_ID=.* ]]; then
            MODERNISATION_ACCOUNT_ID=$(echo "$line" | cut -d'=' -f2 | tr -d '"')
        elif [[ "$line" =~ USER_MP_DIR=.* ]]; then
            USER_MP_DIR=$(echo "$line" | cut -d'=' -f2 | tr -d '"')
        elif [[ "$line" =~ USER_MPE_DIR=.* ]]; then
            USER_MPE_DIR=$(echo "$line" | cut -d'=' -f2 | tr -d '"')
        fi
    done < "$CONFIG_FILE"
}

# Invoke the function to load config from file
load_config

# Define directories based on the loaded configuration
PLATFORM_DIR="$USER_MP_DIR/terraform/environments/$APPLICATION_NAME"
CUSTOMER_DIR="$USER_MPE_DIR/terraform/environments/$APPLICATION_NAME"

# Set account type and directories to process
account_type="member"
DIRECTORIES_TO_PROCESS=("$PLATFORM_DIR")
if [[ "$MEMBER_ACCOUNT" == "no" ]]; then
    account_type="non-member"
else
    DIRECTORIES_TO_PROCESS+=("$CUSTOMER_DIR")
fi

echo "Remember to manually check for resources that require emptying before destruction, such as S3 buckets."

# Function to destroy resources
destroy_resources() {
    local workspace_name=$1
    local target_dir=$2

    local init_args=""
    if [[ "$target_dir" == "$CUSTOMER_DIR" ]]; then
        init_args="-backend-config=assume_role={role_arn=\"arn:aws:iam::$MODERNISATION_ACCOUNT_ID:role/modernisation-account-terraform-state-member-access\"}"
    fi

    echo "Working in directory: $target_dir"
    cd "$target_dir" || { echo "Failed to navigate to the directory $target_dir."; exit 1; }

    echo "Initializing Terraform..."
    terraform init -reconfigure $init_args || { echo "Terraform init failed"; exit 1; }

    echo "Switching to workspace: $workspace_name"
    terraform workspace select $workspace_name 2>/dev/null || terraform workspace new $workspace_name || { echo "Failed to select or create workspace $workspace_name"; exit 1; }

    echo "WARNING: You are about to destroy resources in workspace: $workspace_name"
    read -p "Are you sure you want to continue? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        terraform destroy -auto-approve || { echo "Terraform destroy failed in workspace $workspace_name"; exit 1; }
        echo "Resources destroyed in workspace: $workspace_name"
    else
        echo "Resource destruction cancelled."
        return 1  # Exit the function if destruction is cancelled
    fi
}

# Process each workspace in each directory
for dir in "${DIRECTORIES_TO_PROCESS[@]}"; do
    for workspace in "${WORKSPACES[@]}"; do
        destroy_resources "$workspace" "$dir"
    done
done

echo "All specified workspaces have been processed in all directories. Script execution complete."

