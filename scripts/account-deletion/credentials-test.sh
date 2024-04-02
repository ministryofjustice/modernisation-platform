#!/bin/bash

# Define the path to the credentials file
CREDENTIALS_FILE="config.txt"

# Function to load and export AWS credentials
load_aws_credentials() {
    echo "Loading AWS credentials..."
    while IFS= read -r line; do
        # Check if the line contains export command for AWS credentials
        if [[ "$line" =~ ^export\ AWS_ ]]; then
            # Use eval to execute the export command directly
            eval "$line"
        fi
    done < "$CREDENTIALS_FILE"
    
    # Debugging: Echo the loaded AWS credentials to verify
    echo "Debugging - AWS_ACCESS_KEY_ID is set to: $AWS_ACCESS_KEY_ID"
    echo "Debugging - AWS_SECRET_ACCESS_KEY is set to: $AWS_SECRET_ACCESS_KEY"
    echo "Debugging - AWS_SESSION_TOKEN is set to: $AWS_SESSION_TOKEN"
}

# Load AWS credentials from the file
load_aws_credentials

# Verify if the required AWS environment variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "One or more AWS credentials were not provided in the credentials file. Please check your input and try again."
    exit 1
fi

# Change directory to the Terraform environments (adjust this path as necessary)
echo "Current working directory:"
pwd
cd /Users/kudzai.mtoko/mojgithub/modernisation-platform/terraform/environments || exit
echo "Changed directory to Terraform environments:"
pwd

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# List the current Terraform state
echo "Current Terraform state:"
terraform state list

# Loop through each workspace to plan resources
for ENVIRONMENT in "${WORKSPACES[@]}"; do
    echo "Planning resources for application '$application_name' in the '$ENVIRONMENT' environment."

    # Select the Terraform workspace
    echo "Selecting Terraform workspace '$ENVIRONMENT'"
    terraform workspace select "$ENVIRONMENT" || terraform workspace new "$ENVIRONMENT"

    # Generate and show the plan for the current workspace
    echo "Generating Terraform plan for the '$ENVIRONMENT' environment..."
    terraform plan
done

echo "Terraform plan operations completed."

