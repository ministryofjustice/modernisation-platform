#!/bin/bash

# Some resources such as s3 buckets cannot be destroyed until you manually empty all the objects and versions in them

# Define the path to the configuration script
CONFIG_SCRIPT="config.txt"

# Function to call the appropriate credentials function based on the workspace
set_credentials_based_on_workspace() {
    case "$1" in
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
            PRODUCTION_CREDENTIALS  # Add a case for production environment
            ;;
        *)
            echo "Invalid workspace specified: $1. Skipping."
            return 1
            ;;
    esac
}

# Function to ask for confirmation
ask_for_confirmation() {
    read -p "Do you want to list the Terraform state for workspace $1 in directory $(pwd)? (y/n): " response
    if [[ $response =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Part 1: Managing Resources for MP Environments repo
part_1() {
    echo "Part 1: Managing Resources for MP Environments repo"
    
    # Source the configuration script to load application settings and function definitions
    source "$CONFIG_SCRIPT"

    for WORKSPACE_NAME in "${WORKSPACES[@]}"; do
        # Construct the full workspace name
        WORKSPACE="${APPLICATION_NAME}-${WORKSPACE_NAME}"

        # Load credentials for the current workspace
        set_credentials_based_on_workspace "$WORKSPACE_NAME"
        
        # Check if credentials were successfully loaded
        if [ $? -ne 0 ]; then
            echo "Failed to load credentials for workspace: $WORKSPACE"
            continue
        fi

        # Debugging: Echo the loaded configurations and AWS credentials to verify
        echo "Loaded application name: $APPLICATION_NAME"
        echo "Loaded workspace: $WORKSPACE"
        echo "Debugging - AWS_ACCESS_KEY_ID is set to: $AWS_ACCESS_KEY_ID"
        echo "Debugging - AWS_SECRET_ACCESS_KEY is set to: $AWS_SECRET_ACCESS_KEY"
        echo "Debugging - AWS_SESSION_TOKEN is set to: $AWS_SESSION_TOKEN"
        
        # Verify if the required AWS environment variables are set
        if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
            echo "One or more AWS credentials were not provided for workspace: $WORKSPACE. Skipping."
            continue
        fi

        # Change directory to the Terraform environments (adjust this path as necessary)
        echo "Current working directory:"
        pwd
        cd "$USER_MPE_DIR/terraform/environments/$APPLICATION_NAME" || continue
        echo "Changed directory to Terraform environments:"
        pwd

        # Initialize Terraform (Adjust role_arn and account_id as necessary)
        echo "Initializing Terraform..."
        terraform init -backend-config="assume_role={role_arn=\"arn:aws:iam::$MP_ACCOUNT_ID:role/modernisation-account-terraform-state-member-access\"}"

        # Loop through each workspace and perform Terraform operations
        echo "----------------------------------------------------------------"
        echo "Handling Terraform operations for workspace: $WORKSPACE"
        
        # Selecting Terraform workspace
        echo "Selecting Terraform workspace: $WORKSPACE"
        if terraform workspace select "$WORKSPACE"; then
            echo "Workspace $WORKSPACE selected."
            
            # Ask for confirmation before listing Terraform state
            if ask_for_confirmation "$WORKSPACE"; then
                # List out the current Terraform state for this workspace
                echo "Listing current Terraform state for workspace $WORKSPACE:"
                state_output=$(terraform state list)
                if [ -z "$state_output" ]; then
                    echo "No resources found in Terraform state for workspace $WORKSPACE."
                else
                    echo "$state_output"
                fi
            else
                echo "Skipping listing Terraform state for workspace $WORKSPACE."
            fi
            
        else
            echo "Workspace $WORKSPACE does not exist. Skipping..."
        fi
        
        echo "----------------------------------------------------------------"
    done

    echo "Part 1: Terraform operations completed for MP Environments repo"
}

# Part 2: Managing Resources for MP repo
part_2() {
    echo "Part 2: Managing Resources for MP repo"
    
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
    cd "$USER_MP_DIR/terraform/environments/$APPLICATION_NAME" || exit
    echo "Changed directory to Terraform environments:"
    pwd

    # Initialize Terraform
    echo "Initializing Terraform..."
    terraform init

    # Loop through each workspace and perform Terraform operations
    for WORKSPACE in "${WORKSPACES[@]}"; do
        # Construct the full workspace name
        FULL_WORKSPACE_NAME="${APPLICATION_NAME}-${WORKSPACE}"
        echo "----------------------------------------------------------------"
        echo "Handling Terraform operations for workspace: $FULL_WORKSPACE_NAME"
        
        # Selecting Terraform workspace
        echo "Selecting Terraform workspace: $FULL_WORKSPACE_NAME"
        if terraform workspace select "$FULL_WORKSPACE_NAME"; then
            echo "Workspace $FULL_WORKSPACE_NAME selected."
            
            # Ask user if they want to proceed to list the Terraform state for this workspace
            if ask_for_confirmation $FULL_WORKSPACE_NAME; then
                echo "Current Terraform state for workspace $FULL_WORKSPACE_NAME:"
                terraform state list
            else
                echo "Skipping listing of Terraform state for $FULL_WORKSPACE_NAME."
            fi
        else
            echo "Workspace $FULL_WORKSPACE_NAME does not exist. Skipping..."
        fi
        
        echo "----------------------------------------------------------------"
        # Ask user if they want to proceed to the next workspace
        read -p "Proceed to the next workspace? (y/N): " proceed
        if [[ "$proceed" != [yY] && "$proceed" != [yY][eE][sS] ]]; then
            echo "Exiting as requested by the user."
            exit 0
        fi
    done

    echo "Part 2: Terraform operations completed for MP repo"
}


# Determine which part to execute based on MEMBER_ACCOUNT variable
source "$CONFIG_SCRIPT"
if [[ "$MEMBER_ACCOUNT" == "yes" ]]; then
    part_1
fi

part_2









