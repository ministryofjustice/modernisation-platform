#!/bin/bash

set -euo pipefail

#set parameters
directory="$1"
account="$2"
terraform_action="$3"

#function to loop through the environment workspaces for the associated accounts
run_terraform() {
  echo "Running terraform for workspace in $directory"

    workspaces=`terraform -chdir="$directory" workspace list | grep $account`

    for i in workspaces
    do 
      # Select workspace
      terraform -chdir="$directory" workspace select "$i"

      # Run terraform plan
      if [ "$terraform_action" = "plan" ]; then
        ./scripts/terraform-plan.sh "$directory"
      elif [ "$terraform_action" = "apply" ]; then
        ./scripts/terraform-apply.sh "$directory"
      else
        echo "Unknown terraform command: $terraform_action"
      fi
    done
 
  echo "Finished running terraform for new workspace in $directory"
}

main() {
  if [ -z "$directory" ]; then
    echo "Directory missing: needs to be a directory in which there are Terraform files"
    exit 1
  elif [ -z "$account" ]; then
    echo "No AWS account details provided"
    exit 1
  elif [ -z "$terraform_action" ]; then
    echo "Terraform command missing: (plan/apply)"
    exit 1
  else
    run_terraform "$directory" "$account" "$terraform_action"
  fi
}

# Make terraform-init.sh executable
chmod +x ./scripts/terraform-init.sh

# Make terraform-plan.sh executable
chmod +x ./scripts/terraform-plan.sh

# Make terraform-apply.sh executable
chmod +x ./scripts/terraform-apply.sh

main "$directory" "$account" "$terraform_action"