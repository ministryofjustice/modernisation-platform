#!/bin/bash
set -e

# Define the path to the configuration script
CONFIG_SCRIPT="config.txt"

echo "Listing State for MP repo"

# Define the path to the credentials and configuration file
CONFIG_FILE="config.txt"

# Function to load configurations and AWS credentials from config.sh
load_configurations_and_credentials() {
    echo "Loading configurations and AWS credentials..."
    source "$CONFIG_FILE"
    
    # Call the MP_CREDENTIAL function to load credentials
    MP_CREDENTIALS
    
    # Debugging: Echo the loaded configurations and AWS credentials to verify
    echo "Loaded application name: $APPLICATION_NAME"
    echo "Loaded workspaces: ${WORKSPACES[*]}"
    echo "Debugging - AWS_ACCESS_KEY_ID is set to: $AWS_ACCESS_KEY_ID"
    echo "Debugging - AWS_SECRET_ACCESS_KEY is set to: $AWS_SECRET_ACCESS_KEY"
    echo "Debugging - AWS_SESSION_TOKEN is set to: $AWS_SESSION_TOKEN"
}

# Load configurations and AWS credentials
load_configurations_and_credentials

# Verify if the required AWS environment variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "One or more AWS credentials were not provided in the $CONFIG_FILE. Please check your input and try again."
    exit 1
fi

# Change directory to the Terraform environments (adjust this path as necessary)
echo "Current working directory:"
pwd
cd "$USER_MP_DIR/terraform/environments" || { echo "Failed to navigate to $USER_MP_DIR/terraform/environments"; exit 1; }
echo "Changed directory to Terraform environments:"
pwd

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Loop through each workspace and manage resources
for WORKSPACE in "${WORKSPACES[@]}"; do
  echo "Managing resources for application '$APPLICATION_NAME' in the '$WORKSPACE' environment."

  # Construct the resource to be removed
  RESOURCE_TO_REMOVE="module.environments.aws_organizations_account.accounts[\"$APPLICATION_NAME-$WORKSPACE\"]"

  # Ask for confirmation before removing the resource
  echo "Are you sure you want to remove $RESOURCE_TO_REMOVE from the Terraform state? [y/N]:"
  read -r confirm
  if [[ "$confirm" = [yY] ]]; then
    echo "Removing $RESOURCE_TO_REMOVE from the Terraform state..."
    terraform state rm "$RESOURCE_TO_REMOVE"
  else
    echo "Skipping removal of $RESOURCE_TO_REMOVE."
  fi
done

echo "Resource management operations completed."