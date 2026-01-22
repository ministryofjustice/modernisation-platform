#!/bin/bash

set -Eeuo pipefail

basedir=terraform/environments
application=${1} # eg sprinkler
environment=${2} # eg development

# Use terraform plan or apply based on TERRAFORM_ACTION env var
terraform_action=${TERRAFORM_ACTION:-apply}

echo "Application: ${application}"
echo "Environment: ${environment}"
echo "Terraform action: ${terraform_action}"

setup_ram_share_association() {

    #Runs a Terraform plan/apply in the member-vpc workspace to setup the RAM association
    echo "Running terraform across workspace ${application}-${environment}"

    echo "Terraform init"
    ./scripts/terraform-init.sh "${basedir}/${application}"

    # Select workspace
    select_workspace=`terraform -chdir="${basedir}/${application}" workspace select "${application}-${environment}"`
    
    if [[ $select_workspace ]]; then

      if [[ "${terraform_action}" == "plan" ]]; then
        # Plan only mode - show what would change
        echo "[+] Running terraform plan (no changes will be applied)"
        terraform -chdir="${basedir}/${application}" plan -target=module.ram-ec2-retagging[0].data.aws_subnets.associated
        echo "[+] Full plan:"
        terraform -chdir="${basedir}/${application}" plan
      else
        # Normal apply mode
        # Run terraform apply to get subnet info
        ./scripts/terraform-apply.sh $basedir/$application -target=module.ram-ec2-retagging[0].data.aws_subnets.associated
        # Run the full terraform apply
        ./scripts/terraform-apply.sh $basedir/$application
      fi
    fi
    echo "Finished running ram share association for application: ${application}"
    exit 0
}

setup_ram_share_association
