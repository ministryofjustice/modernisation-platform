#!/bin/bash

# Warning Messages
echo -e "*** WARNING *** Remember to manually check for resources that require emptying before destruction, such as S3 buckets. \n"

# User inputs

# Prompt for temporary AWS Administrator Access credentials for the Modernisation Platform AWS Account
echo "Paste the AWS Admin credentials for the Modernisation Platform AWS Account:"
IFS=$'\n' read -r -d '' -a mp_credentials

echo "Please enter the application name for the environment/s you want to delete:"
read application_name

WORKSPACES=()

echo "Do you want to delete the development environment? (y/n)"
read delete_development
[[ "$delete_development" =~ ^[Yy]$ ]] && WORKSPACES+=("development") && echo "Paste the AWS Admin credentials for the Modernisation Platform AWS Account:" && IFS=$'\n' read -r -d '' -a development_credentials

echo $development_credentials

echo $mp_credentials


# echo "Do you want to delete the test environment? (y/n)"
# read delete_test
# [[ "$delete_test" =~ ^[Yy]$ ]] && WORKSPACES+=("test")

# echo "Do you want to delete the preproduction environment? (y/n)"
# read delete_preproduction
# [[ "$delete_preproduction" =~ ^[Yy]$ ]] && WORKSPACES+=("preproduction")

# echo "Do you want to delete the production environment? (y/n)"
# read delete_production
# [[ "$delete_production" =~ ^[Yy]$ ]] && WORKSPACES+=("production")


# echo "Please enter the Modernisation Platform account ID:"
# read modernisation_account_id

# echo "Is this operation for a member account? (y/n):"
# read -r is_non_member
# account_type="member"





# read -p "You are deleting these environments: *** ${WORKSPACES[@]} ***
# For the application: *** $application_name *** 
# The account type is *** $account_type ***
# The modernisation Platform ID is: *** $modernisation_account_id ***
# Do you want to proceed? (y/n) " yn

# case $yn in 
# 	y ) echo ok, we will proceed;;
# 	n ) echo exiting...;
# 		exit;;
# 	* ) echo invalid response;
# 		exit 1;;
# esac

# # Git Setup

# # Clone down repos and create branches
# timestamp=$(date +%s)

# git clone https://github.com/ministryofjustice/modernisation-platform
# echo "Creating a branch in MP repo"
# cd modernisation-platform
# git checkout -b "delete-$application_name-environments-$timestamp"
# cd ..

# if [[ $account_type == "member"  ]]; then
#   git clone https://github.com/ministryofjustice/modernisation-platform-environments
#   echo "Creating a branch in MP repo"
#   cd modernisation-platform-environments
#   git checkout -b "delete-$application_name-environments-$timestamp"
#   cd ..
# fi

# # -a credential_lines stores the read lines into an array named credential_lines.

# # Removing the AWS account from Modernisation Platform management

# remove_from_mp_management() {

#     # Prompt for temporary AWS Administrator Access credentials for the Modernisation Platform AWS Account
#     echo "Paste the AWS Admin credentials for the Modernisation Platform AWS Account:"
#     IFS=$'\n' read -r -d '' -a credential_lines

#     # Export the credentials for use by AWS CLI and Terraform
#     for line in "${credential_lines[@]}"; do
#       if [[ $line =~ AWS_ACCESS_KEY_ID ]]; then
#         export AWS_ACCESS_KEY_ID=$(echo "$line" | cut -d '=' -f2 | tr -d '”“')
#       elif [[ $line =~ AWS_SECRET_ACCESS_KEY ]]; then
#         export AWS_SECRET_ACCESS_KEY=$(echo "$line" | cut -d '=' -f2 | tr -d '”“')
#       elif [[ $line =~ AWS_SESSION_TOKEN ]]; then
#         export AWS_SESSION_TOKEN=$(echo "$line" | cut -d '=' -f2 | tr -d '”“')
#       fi
#     done

#     # Verify if the required variables are set
#     if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
#       echo "One or more AWS credentials were not provided. Please check your input and try again."
#       exit 1
#     fi

#     # Change directory to the Terraform environments
#     cd terraform/environments || exit

#     # Initialize Terraform
#     echo "Initializing Terraform..."
#     terraform init

#     # List the current Terraform state
#     echo "Current Terraform state:"
#     terraform state list

#     # Loop through each workspace and manage resources
#     for ENVIRONMENT in "${WORKSPACES[@]}"; do
#       echo "Managing resources for application '$application_name' in the '$ENVIRONMENT' environment."

#       # Construct the resource to be removed
#       RESOURCE_TO_REMOVE="module.environments.aws_organizations_account.accounts[\"$application_name-$ENVIRONMENT\"]"

#       # Ask for confirmation before removing the resource
#       echo "Are you sure you want to remove $RESOURCE_TO_REMOVE from the Terraform state? [y/N]:"
#       read -r confirm
#       if [[ "$confirm" = [yY] ]]; then
#         echo "Removing $RESOURCE_TO_REMOVE from the Terraform state..."
#         terraform state rm "$RESOURCE_TO_REMOVE"
#       else
#         echo "Skipping removal of $RESOURCE_TO_REMOVE."
#       fi
#     done

#     echo "Resource management operations completed."
# }


# Removing the environment definition



# Delete Terraform resources for the environment



# Delete Terraform workspaces for the environment



# Remove Environment Files (*only if removing all environments for an application) 













# cd ../../modernisation-platform/environments

# # Check the exit status of the command
# if [ $? -ne 0 ]; then
#     echo "Are you running this in the scripts directory?"
#     echo "Exiting the script."
#     exit 1
# fi

# # Git setup
# echo "Creating a branch"
# timestamp=$(date +%s)
# git checkout -b "delete-$application_name-$workspace-$timestamp"

# # Delete the environment from the application.json file (or the whole file)
# if [[ $workspace != "all" ]]; then
#     echo "Deleting $workspace from $application_name.json"
#     jq "del(.environments[] | select(.name == \"$workspace\"))" $application_name.json > $application_name.tmp
#     mv $application_name.tmp $application_name.json
# else 
#     echo "Deleting $application_name.json"
#     rm $application_name.json
# fi

# # Delete the environment from environments-networks.json files
# business_unit=$(jq -r '.tags."business-unit"' $application_name.json | tr "[:upper:]" "[:lower:]")
# account=$application_name-$workspace
# echo "Removing all references to $account in $business_unit-$workspace.json"
# cd ../environments-networks
# jq ".cidr."subnet_sets".general.accounts |= map(select(. != \"$account\"))" $business_unit-$workspace.json > $business_unit-$workspace.tmp
# mv $business_unit-$workspace.tmp $business_unit-$workspace.json

# # Delete environment from opa test policies
# echo "Removing all references to $workspace in environments/expected.rego"
# cd ../policies/environments
# sed -i '' -e "/$application_name/d" expected.rego

# echo "Removing all references to $account in networking/expected.rego"
# cd ../networking
# sed -i '' -e "/$account/d" expected.rego

# # Deleting Terraform Resources

# #!/bin/bash

# echo "Remember to manually check for resources that require emptying before destruction, such as S3 buckets."

# # Define the workspaces you want to manage
# WORKSPACES=("dev" "qa" "preprod" "prod")

# echo "Enter the application name for which you want to manage resources:"
# read application_name

# echo "Enter the Modernisation Platform account ID:"
# read modernisation_account_id

# PLATFORM_DIR="modernisation-platform/terraform/environments/$application_name"
# CUSTOMER_DIR="modernisation-platform-environments/terraform/environments/$application_name"

# echo "Is this operation for a non-member account? (yes/no):"
# read -r is_non_member
# account_type="member"
# DIRECTORIES_TO_PROCESS=("$PLATFORM_DIR")
# if [[ "$is_non_member" =~ ^[Yy]es$ ]]; then
#     account_type="non-member"
# else
#     # Member account type; add CUSTOMER_DIR to the directories to process
#     DIRECTORIES_TO_PROCESS+=("$CUSTOMER_DIR")
# fi

# destroy_resources() {
#     local workspace_name=$1
#     local target_dir=$2

#     local init_args=""
#     if [[ "$target_dir" == "$CUSTOMER_DIR" ]]; then
#         init_args="-backend-config=assume_role={role_arn=\"arn:aws:iam::$modernisation_account_id:role/modernisation-account-terraform-state-member-access\"}"
#     fi

#     echo "Working in directory: $target_dir"
#     cd "$target_dir" || { echo "Failed to navigate to the directory $target_dir."; exit 1; }

#     # Initialize Terraform with conditional backend configuration
#     echo "Initializing Terraform..."
#     terraform init -reconfigure $init_args || { echo "Terraform init failed"; exit 1; }

#     # Terraform workspace management
#     echo "Switching to workspace: $workspace_name"
#     terraform workspace select $workspace_name 2>/dev/null || terraform workspace new $workspace_name || { echo "Failed to select or create workspace $workspace_name"; exit 1; }

#     # Confirm before destroying resources
#     echo "WARNING: You are about to destroy resources in workspace: $workspace_name"
#     read -p "Are you sure you want to continue? (y/n): " confirm
#     if [[ "$confirm" =~ ^[Yy]$ ]]; then
#         terraform destroy -auto-approve || { echo "Terraform destroy failed in workspace $workspace_name"; exit 1; }
#         echo "Resources destroyed in workspace: $workspace_name"
#     else
#         echo "Resource destruction cancelled."
#         return 1  # Exit the function if destruction is cancelled
#     fi
# }

# # Process each workspace in each directory
# for dir in "${DIRECTORIES_TO_PROCESS[@]}"; do
#     for workspace in "${WORKSPACES[@]}"; do
#         destroy_resources "$workspace" "$dir"
#     done
# done

# echo "All specified workspaces have been processed in all directories. Script execution complete."

# # Deleting Resources from State

# #!/bin/bash

# # Define the workspaces you want to manage
# WORKSPACES=("development" "test" "preproduction" "production")

# echo "Enter the application name:"
# read -r application_name

# # Prompt for temporary AWS Administrator Access credentials for the Modernisation Platform AWS Account
# echo "Paste the AWS Admin credentials for the Modernisation Platform AWS Account:"
# IFS=$'\n' read -r -d '' -a credential_lines

# # Export the credentials for use by AWS CLI and Terraform
# for line in "${credential_lines[@]}"; do
#   if [[ $line =~ AWS_ACCESS_KEY_ID ]]; then
#     export AWS_ACCESS_KEY_ID=$(echo "$line" | cut -d '=' -f2 | tr -d '”“')
#   elif [[ $line =~ AWS_SECRET_ACCESS_KEY ]]; then
#     export AWS_SECRET_ACCESS_KEY=$(echo "$line" | cut -d '=' -f2 | tr -d '”“')
#   elif [[ $line =~ AWS_SESSION_TOKEN ]]; then
#     export AWS_SESSION_TOKEN=$(echo "$line" | cut -d '=' -f2 | tr -d '”“')
#   fi
# done

# # Verify if the required variables are set
# if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
#   echo "One or more AWS credentials were not provided. Please check your input and try again."
#   exit 1
# fi

# # Change directory to the Terraform environments
# cd terraform/environments || exit

# # Initialize Terraform
# echo "Initializing Terraform..."
# terraform init

# # List the current Terraform state
# echo "Current Terraform state:"
# terraform state list

# # Loop through each workspace and manage resources
# for ENVIRONMENT in "${WORKSPACES[@]}"; do
#   echo "Managing resources for application '$application_name' in the '$ENVIRONMENT' environment."

#   # Construct the resource to be removed
#   RESOURCE_TO_REMOVE="module.environments.aws_organizations_account.accounts[\"$application_name-$ENVIRONMENT\"]"

#   # Ask for confirmation before removing the resource
#   echo "Are you sure you want to remove $RESOURCE_TO_REMOVE from the Terraform state? [y/N]:"
#   read -r confirm
#   if [[ "$confirm" = [yY] ]]; then
#     echo "Removing $RESOURCE_TO_REMOVE from the Terraform state..."
#     terraform state rm "$RESOURCE_TO_REMOVE"
#   else
#     echo "Skipping removal of $RESOURCE_TO_REMOVE."
#   fi
# done

# echo "Resource management operations completed."


# # IFS=$'\n' - ensures that input is split into lines.
# # read -r -d '' reads multiple lines until an end-of-file character (triggered by pressing Ctrl+D after pasting).
# # -a credential_lines stores the read lines into an array named credential_lines.



# # Ed's script to delete workspaces
# #!/bin/bash

# echo "Dont forget to use your mod plat credentials before running this script"
# echo "Please enter the application name you would like to kill"
# read application_name
# echo "Please enter the workspace you would like to kill"
# read workspace

# echo "You have selected,$application_name and $workspace! Lets gooo."

# cd ../../modernisation-platform/terraform/environments/bootstrap/


# # Check the exit status of the command
# if [ $? -ne 0 ]; then
#     echo "Are you running this in the scripts directory?"
#     echo "Exiting the script."
#     exit 1
# fi

# # Define the list of directories
# directories=("delegate-access" "secure-baselines" "single-sign-on" "member-bootstrap")

# for dir in "${directories[@]}"; do
#     cd "$dir" || { echo "Failed to navigate to $dir"; exit 1; }
#     terraform init > /dev/null 2>&1
#     terraform workspace select default
#     pwd
#     echo "Here I will run terraform workspace delete -force $workspace"
#     # Return to the original directory
#     cd - > /dev/null
# done
