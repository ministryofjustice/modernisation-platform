#!/bin/bash

set -Eeuo pipefail

basedir=terraform/environments
environment=${2}
account=`echo ${1} | sed -e "s/-${environment}//g"`

echo "Environment: ${environment}"
echo "Account: ${account}"

setup_ram_share_association() {

    
    #Runs a Terraform plan/apply in the member-vpc workspace to setup the RAM association
    echo "Running terraform across workspace ${account}-${environment}"

    echo "Terraform init"
    ./scripts/terraform-init.sh "${basedir}/${account}"

    # Select workspace
    select_workspace=`terraform -chdir="${basedir}/${account}" workspace select "${account}-${environment}"`
    
    if [[ $select_workspace ]]; then

      # Run terraform apply
      ./scripts/terraform-apply.sh $basedir/$account
    fi
    echo "Finished running ram share association for account: ${account}"
}

setup_ram_share_association
