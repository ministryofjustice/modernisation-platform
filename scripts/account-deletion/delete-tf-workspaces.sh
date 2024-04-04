#!/bin/bash

# Define the path to the credentials and configuration file
CONFIG_FILE="config.txt"

# Function to ask for confirmation
ask_for_confirmation() {
    read -p "Do you want to delete the $APPLICATION_NAME-$workspace workspace in terraform/environments/bootstrap/* ? (y/n): " response
    if [[ $response =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to load configurations and AWS credentials from config.sh
load_configurations_and_credentials() {
    echo "Loading configurations and AWS credentials..."
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

# Load configurations and AWS credentials
load_configurations_and_credentials

# Verify if the required AWS environment variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "One or more AWS credentials were not provided in the $CONFIG_FILE. Please check your input and try again."
    exit 1
fi

# Define the list of directories
directories=("$USER_MP_DIR/terraform/environments/bootstrap/delegate-access" "$USER_MP_DIR/terraform/environments/bootstrap/secure-baselines" "$USER_MP_DIR/terraform/environments/bootstrap/single-sign-on" "$USER_MP_DIR/terraform/environments/bootstrap/member-bootstrap")

for workspace in "${WORKSPACES[@]}"; do
    if ask_for_confirmation; then 
        for dir in "${directories[@]}"; do
            cd "$dir" || { echo "Failed to navigate to $dir"; exit 1; }
            terraform init > /dev/null 2>&1
            terraform workspace select default
            pwd
            echo "Here I will run terraform workspace delete -force $APPLICATION_NAME-$workspace"
            terraform workspace select $APPLICATION_NAME-$workspace # terraform workspace delete -force $APPLICATION_NAME-$workspace
        done
    else
        exit 1
    fi
done