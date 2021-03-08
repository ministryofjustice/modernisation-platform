#!/usr/bin/env bash

# This script provisions Terraform workspaces. It does not run terraform plan or terraform apply.
#
# You need to pass through an argument to this script:
#
# bootstrap (`sh scripts/provision-terraform-workspaces.sh bootstrap`)
# Using the `bootstrap` argument will create Terraform workspaces for all applications and their environments
# within terraform/environments/bootstrap/* subdirectories.
# Use case: to create Terraform workspaces for bootstrap steps.
#
# all-environments (`sh scripts/provision-terraform-workspaces.sh all-environments`)
# Using the `all-environments` argument will create Terraform workspaces for all applications and their environments
# within terraform/environments/${application_name} subdirectories.
# Use case: to ensure all applications workspaces are configured.
#
# any application name (e.g `sh scripts/provision-terraform-workspaces.sh core-vpc`)
# Passing through an application name will create Terraform workspaces for an application's environments,
# within their terraform/environments/${application_name} subdirectory.
# Use case: to ensure a single applications workspaces are configured (e.g. if a new environment is created).

TMP_DIR=tmp/terraform-workspaces
TF_ENV_DIR=terraform/environments

iterate_environments() {
# Loop through each application json file
for JSON_FILE in ${git_dir}/environments/${3}.json
do
APPLICATION=`basename "${JSON_FILE}" .json`

  # Build temporary folder to emulate real folder
  if  [ "${2}" != "bootstrap" ]
  then
      if [ -d "${git_dir}/tmp" ]
      then
        rm -r "${git_dir}/tmp"
      fi
      mkdir "${git_dir}/tmp"
      # Copy files to emulation folder
      sed "s/\$application_name/${APPLICATION}/g" "${git_dir}/terraform/templates/backend.tf" > "${git_dir}/tmp/backend.tf"
      sed "s/\$application_name/${APPLICATION}/g" "${git_dir}/terraform/templates/locals.tf" > "${git_dir}/tmp/locals.tf"
      cp "${git_dir}/terraform/templates/providers.tf" "${git_dir}/tmp/providers.tf"
      cp "${git_dir}/terraform/templates/secrets.tf" "${git_dir}/tmp/secrets.tf"
      cp "${git_dir}/terraform/templates/versions.tf" "${git_dir}/tmp/versions.tf"
  fi

  # Loop through each environment for specific application
  for ENV in `cat "${JSON_FILE}" | jq -r --arg FILENAME "${APPLICATION}" '.environments[].name'`
  do
    # Check if state file exists in S3
    if [ "${2}" = "bootstrap" ]
    then
      # For Bootstrap files
      aws s3api head-object --bucket modernisation-platform-terraform-state --key "environments/${1}/${APPLICATION}-${ENV}/terraform.tfstate"  > /dev/null 2>&1
      RETURN_CODE="${?}"
    else
      aws s3api head-object --bucket modernisation-platform-terraform-state --key "environments/${APPLICATION}/${APPLICATION}-${ENV}/terraform.tfstate" > /dev/null 2>&1 
      RETURN_CODE="${?}"
    fi
    
    echo "${1}       ${APPLICATION}-${ENV}:-------Return Code: ${RETURN_CODE}"
  
    if [[ "${RETURN_CODE}" -ne 0 ]]
    then
      [ "${2}" = "bootstrap" ] && TERRAFORM_PATH="${git_dir}/terraform/environments/${1}" || TERRAFORM_PATH="${git_dir}/tmp"
      # move to Terraform environment folder
      echo "terraform working folder:    ${TERRAFORM_PATH}"
      terraform -chdir="${TERRAFORM_PATH}" init > /dev/null
      terraform -chdir="${TERRAFORM_PATH}" workspace new "${APPLICATION}-${ENV}"
    fi
 
  done
done
}

main() {
# Set root path to repository
git_dir="$( git rev-parse --show-toplevel )"

# Determine workspace build type
case "${1}" in
all-environments)
  iterate_environments "" "${1}" "*"
  ;;
bootstrap)
  iterate_environments "bootstrap/delegate-access" "${1}" "*"
  iterate_environments "bootstrap/secure-baselines" "${1}" "*"
  iterate_environments "bootstrap/single-sign-on" "${1}" "*"
  ;;
*)
  # Check if folder exists for application
  if [ -f ${git_dir}/environments/${1}.json ]
  then
    iterate_environments "" "${1}" "${1}"
  else
    echo "ERROR: Incorrect Parameter received"
    exit 1
  fi
  ;;
esac
}

main "${1}"
