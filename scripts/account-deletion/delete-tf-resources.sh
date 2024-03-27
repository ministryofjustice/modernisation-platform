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
        elif [[ "$line" =~ MP_CREDENTIALS=.* ]]; then
            IFS="(" read -ra MP_CREDENTIALS <<< "$(echo "$line" | cut -d'=' -f2 | tr -d '()')"
        fi
    done < "$CONFIG_FILE"

    # Export MP_CREDENTIALS
    for cred in "${MP_CREDENTIALS[@]}"; do
        eval "$cred"
    done
}

# Invoke the function to load config from file
load_config

# Verify if the required variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "One or more AWS credentials were not provided in the config file. Please check your input and try again."
  exit 1
fi

# Define directories based on the loaded configuration
PLATFORM_DIR="$USER_MP_DIR/terraform/environments/$APPLICATION_NAME"
CUSTOMER_DIR="$USER_MPE_DIR/terraform/environments/$APPLICATION_NAME"

# Set account type and directories to process
if [[ "$MEMBER_ACCOUNT" == "no" ]]; then
    account_type="non-member"
    DIRECTORIES_TO_PROCESS=("$PLATFORM_DIR")
else
    # For member accounts, start with the customer directory
    DIRECTORIES_TO_PROCESS=("$CUSTOMER_DIR" "$PLATFORM_DIR")
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
    terraform init $init_args || { echo "Terraform init failed"; exit 1; }

    echo "Switching to workspace: $workspace_name"
    terraform workspace select $workspace_name 2>/dev/null || terraform workspace new $workspace_name || { echo "Failed to select or create workspace $workspace_name"; exit 1; }

    echo "WARNING: You are about to destroy resources in workspace: $workspace_name"
    read -p "Are you sure you want to continue? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        terraform destroy -auto-approve || { echo "Terraform destroy failed in workspace $workspace_name"; exit 1; }
        echo "Resources destroyed in workspace: $workspace_name"
    else
        echo "Resource destruction"
    fi
}

# Rest of the script...




