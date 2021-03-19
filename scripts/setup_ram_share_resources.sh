#!/bin/bash

basedir=terraform/environments

envs=("production", "preproduction", "test", "development")

application_name="$1"

echo "Setting up for application: $application_name"

setup_ram_share_core() {

    #Runs a Terraform plan/apply in the core-vpc-<env> to create the RAM share and association

    for env in "${envs[@]}"; do

    echo "Running terraform across core accounts core-vpc-$env"

    # Select workspace
    select_workspace=`terraform -chdir=$basedir/core-vpc workspace select core-vpc-$env`

    if [[ $select_workspace ]]; then

       echo "Terraform init"
      ./scripts/terraform-init.sh "$basedir/core-vpc"

      echo "Terraform plan"
      # Run terraform plan
      ./scripts/terraform-plan.sh "$basedir/core-vpc"

      # Run terraform apply
      #./scripts/terraform-apply.sh $basedir/core-vpc
    fi
    echo "Finished running terraform across vpc-core accounts"
   
    done

setup_ram_share_association() {

    #Runs a Terraform plan/apply in the member-vpc workspace to setup the RAM association

    for env in "${envs[@]}"; do

    echo "Running terraform across new workspace $application_name-$env"

    # Select workspace
    select_workspace=`terraform -chdir=$basedir/$application_name workspace select $application-$env`

    if [[ $select_workspace ]]; then
        
       echo "Terraform init" 
      ./scripts/terraform-init.sh "$basedir/$application_name"

        # Run terraform plan
      echo "Terraform plan"
      ./scripts/terraform-plan.sh "$basedir/$application_name"

      # Run terraform apply
      #./scripts/terraform-apply.sh $basedir/$application_name
    fi 
    echo "Finished running terraform across new accoutn: $application_name"

    done
}
}

setup_ram_share_core
setup_ram_share_association
