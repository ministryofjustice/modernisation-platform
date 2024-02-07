#!/bin/bash

set -Eeuo pipefail

basedir=terraform/environments
application=${1} # eg sprinkler
environment=${2} # eg development

echo "Application: ${application}"
echo "Environment: ${environment}"

setup_ram_share_association() {

    #Runs a Terraform plan/apply in the member-vpc workspace to setup the RAM association
    echo "Running terraform across workspace ${application}-${environment}"

    echo "Terraform init"
    ./scripts/terraform-init.sh "${basedir}/${application}"

    # Select workspace
    select_workspace=`terraform -chdir="${basedir}/${application}" workspace select "${application}-${environment}"`
    
    if [[ $select_workspace ]]; then

      # Run terraform apply to get subnet info
      ./scripts/terraform-apply.sh $basedir/$application -target=module.ram-ec2-retagging[0].data.aws_subnets.associated
      # Run the full terraform apply
      ./scripts/terraform-apply.sh $basedir/$application
    fi
    echo "Finished running ram share association for application: ${application}"
    exit 0
}

setup_ram_share_association
