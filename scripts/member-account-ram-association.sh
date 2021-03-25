#!/bin/bash

basedir=terraform/environments
account=$1
environment=$2

setup_ram_share_association() {

    #Runs a Terraform plan/apply in the member-vpc workspace to setup the RAM association

    echo "Running terraform across workspace $account-$environment"

    # Select workspace
    select_workspace=`terraform -chdir=$basedir/$account workspace select $account-$environment`

    if [[ $select_workspace ]]; then
        
       echo "Terraform init" 
      ./scripts/terraform-init.sh "$basedir/$account"

        # Run terraform plan
      echo "Terraform plan"
      ./scripts/terraform-plan.sh "$basedir/$account"

      # Run terraform apply
      ./scripts/terraform-apply.sh $basedir/$account
    fi 
    echo "Finished running terraform across new account: $account-$environment"
}
}

setup_ram_share_association
