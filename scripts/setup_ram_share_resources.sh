#!/bin/bash

exit 1

basedir=terraform/environments

envs=("production", "preproduction", "test", "development")

application_name="$1"

setup_ram_share_core() {

    #Runs a Terraform plan/apply in the core-vpc-<env> to create the RAM share and association

    for env "${envs[@]}"; do

    echo "Running terraform across core accounts core-vpc-$env"

    # Select workspace
    select_workspace=`terraform -chdir="$basedir/core-vpc" workspace select "core-vpc-$env"`

    if [[ $select_workspace ]]; then

      # Run terraform plan
      ./scripts/terraform-plan.sh "$basedir/core-vpc-$env"

      # Run terraform apply
      #./scripts/terraform-apply.sh $basedir/core-vpc
    fi
    echo "Finished running terraform across new workspaces in $application_name-$env"
   
    done

setup_ram_share_association() {

    #Runs a Terraform plan/apply in the member-vpc workspace to setup the RAM association

    for env "${envs[@]}"; do

    echo "Running terraform across new workspace $application_name-$env"

    # Select workspace
    select_workspace=`terraform -chdir="$basedir/$application_name" workspace select "$application-$env"`

    if [[ $select_workspace ]]; then

        # Run terraform plan
      ./scripts/terraform-plan.sh "$basedir/$application_name"

      # Run terraform apply
      #./scripts/terraform-apply.sh $basedir/$application_name
    fi 
    echo "Finished running terraform across new workspaces in $application_name-$env"

    done
}
}

setup_ram_share_core
setup_ram_share_association
