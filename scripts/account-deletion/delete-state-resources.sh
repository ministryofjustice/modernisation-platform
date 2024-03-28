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
            application_name=$(echo "$line" | cut -d'=' -f2 | tr -d '"')
        elif [[ "$line" =~ AWS_ACCESS_KEY_ID=.* ]]; then
            export AWS_ACCESS_KEY_ID=$(echo "$line" | cut -d'=' -f2 | tr -d '”“')
        elif [[ "$line" =~ AWS_SECRET_ACCESS_KEY=.* ]]; then
            export AWS_SECRET_ACCESS_KEY=$(echo "$line" | cut -d'=' -f2 | tr -d '”“')
        elif [[ "$line" =~ AWS_SESSION_TOKEN=.* ]]; then
            export AWS_SESSION_TOKEN=$(echo "$line" | cut -d'=' -f2 | tr -d '”“')
        fi
    done < "$CONFIG_FILE"
}

# Invoke the function to load config from file
load_config

# Verify if the required variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "One or more AWS credentials were not provided in the config file. Please check your input and try again."
  exit 1
fi

# Change directory to the Terraform environments
# This needs to be changed to be more dynamic
cd "/Users/kudzai.mtoko/mojgithub/modernisation-platform/terraform/environments" || exit

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# List the current Terraform state
echo "Current Terraform state:"
terraform state list

# Loop through each workspace and manage resources
for ENVIRONMENT in "${WORKSPACES[@]}"; do
  echo "Managing resources for application '$application_name' in the '$ENVIRONMENT' environment."

  # Construct the resource to be removed
  RESOURCE_TO_REMOVE="module.environments.aws_organizations_account.accounts[\"$application_name-$ENVIRONMENT\"]"

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
