#!/bin/bash

echo "Remember to manually check for resources that require emptying before destruction, such as S3 buckets."

# Initial user prompts
echo "Please enter the application name for the environment/s you want to delete:"
read application_name

echo "Enter the Modernisation Platform account ID:"
read modernisation_account_id

PLATFORM_DIR="modernisation-platform/terraform/environments/$application_name"
CUSTOMER_DIR="modernisation-platform-environments/terraform/environments/$application_name"

echo "Is this operation for a non-member account? (y/n):"
read -r is_non_member
account_type="member"
DIRECTORIES_TO_PROCESS=("$PLATFORM_DIR")
if [[ "$is_non_member" =~ ^[Yy]$ ]]; then
    account_type="non-member"
else
    DIRECTORIES_TO_PROCESS+=("$CUSTOMER_DIR")
fi

# Dynamically creating the list of workspaces to process based on user input
WORKSPACES=()
echo "Do you want to delete the development environment? (y/n)"
read delete_development
[[ "$delete_development" =~ ^[Yy]$ ]] && WORKSPACES+=("development")

echo "Do you want to delete the test environment? (y/n)"
read delete_test
[[ "$delete_test" =~ ^[Yy]$ ]] && WORKSPACES+=("test")

echo "Do you want to delete the preproduction environment? (y/n)"
read delete_preproduction
[[ "$delete_preproduction" =~ ^[Yy]$ ]] && WORKSPACES+=("preproduction")

echo "Do you want to delete the production environment? (y/n)"
read delete_production
[[ "$delete_production" =~ ^[Yy]$ ]] && WORKSPACES+=("production")

destroy_resources() {
    local workspace_name=$1
    local target_dir=$2

    local init_args=""
    if [[ "$target_dir" == "$CUSTOMER_DIR" ]]; then
        init_args="-backend-config=assume_role={role_arn=\"arn:aws:iam::$modernisation_account_id:role/modernisation-account-terraform-state-member-access\"}"
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
