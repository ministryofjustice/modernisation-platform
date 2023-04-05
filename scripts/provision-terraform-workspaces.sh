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

iterate_environments_bootstrap() {
# set friendly Parameter names
BOOTSTRAP_TYPE="${1}"  # this value can equal (delegate-access, secure-baselines, single-sign-on or member-bootstrap)


# Loop through each application json file
for JSON_FILE in ${git_dir}/environments/*.json
do
APPLICATION=`basename "${JSON_FILE}" .json`

  # Loop through each environment for specific application
  for ENV in `cat "${JSON_FILE}" | jq -r --arg FILENAME "${APPLICATION}" '.environments[].name'`
  do
    # Check if state file exists in S3
      aws s3api head-object --bucket modernisation-platform-terraform-state --key "environments/bootstrap/${BOOTSTRAP_TYPE}/${APPLICATION}-${ENV}/terraform.tfstate"  > /dev/null 2>&1
      RETURN_CODE="${?}"

    if [[ "${RETURN_CODE}" -ne 0 ]]
    then
      TERRAFORM_PATH="${git_dir}/terraform/environments/bootstrap/${BOOTSTRAP_TYPE}"
      echo -en "BOOTSTRAP - ${BOOTSTRAP_TYPE} - ${APPLICATION}-${ENV} - ${YELLOW}CREATING${NORMAL}\n"
      terraform -chdir="${TERRAFORM_PATH}" init > /dev/null
      terraform -chdir="${TERRAFORM_PATH}" workspace new "${APPLICATION}-${ENV}"
    else
      echo -en "BOOTSTRAP - ${BOOTSTRAP_TYPE} - ${APPLICATION}-${ENV} - ${GREEN}EXISTS${NORMAL}\n"
    fi

  done
done
}

create_tmp_terraform_files() {
  # Build temporary folder to emulate real folder
  [ -d "${git_dir}/tmp" ] && rm -r "${git_dir}/tmp"
  mkdir "${git_dir}/tmp"

  # Copy files to emulation folder

  # copy the correct backend if environments or main repo (the other files are the same)
  if [[ "${1}" == "environments-repo" ]]
  then
    sed "s/\$application_name/${APPLICATION}/g" "${git_dir}/terraform/templates/modernisation-platform-environments/platform_backend.tf" > "${git_dir}/tmp/platform_backend.tf"
  else
    sed "s/\$application_name/${APPLICATION}/g" "${git_dir}/terraform/templates/modernisation-platform/platform_backend.tf" > "${git_dir}/tmp/platform_backend.tf" 
  fi
  cp "${git_dir}/terraform/templates/modernisation-platform/providers.tf" "${git_dir}/tmp/providers.tf"
  cp "${git_dir}/terraform/templates/modernisation-platform/platform_secrets.tf" "${git_dir}/tmp/platform_secrets.tf"
  cp "${git_dir}/terraform/templates/modernisation-platform/platform_versions.tf" "${git_dir}/tmp/platform_versions.tf"
}

iterate_environments_member() {
# set friendly Parameter names
ENVIRONMENT_TYPE="${1}"  # this value can equal (* or an application name)

# Loop through each application json file
for JSON_FILE in ${git_dir}/environments/${ENVIRONMENT_TYPE}.json
do
  APPLICATION=`basename "${JSON_FILE}" .json`

  # Loop through each environment for specific application to check if state file exists in S3
  for ENV in `cat "${JSON_FILE}" | jq -r --arg FILENAME "${APPLICATION}" '.environments[].name'`
  do
    # Check if state file exists in S3 for modernisation-platform repository
    aws s3api head-object --bucket modernisation-platform-terraform-state --key "environments/accounts/${APPLICATION}/${APPLICATION}-${ENV}/terraform.tfstate" > /dev/null 2>&1
    RETURN_CODE_CORE_REPO="${?}"
    # Check if state file exists in S3 for modernisation-platform-environments repository
    aws s3api head-object --bucket modernisation-platform-terraform-state --key "environments/members/${APPLICATION}/${APPLICATION}-${ENV}/terraform.tfstate" > /dev/null 2>&1
    RETURN_CODE_MEMBER_REPO="${?}"

    create_tmp_terraform_files

    # Creating MEMBER account state file for modernisation-platform if it does not exist
    TERRAFORM_PATH="${git_dir}/tmp"
    if [[ "${RETURN_CODE_CORE_REPO}" -ne 0 ]]
    then
      echo -en "MEMBER ACCOUNT IN CORE REPO      - ${APPLICATION}-${ENV} - ${YELLOW}CREATING${NORMAL}\n"
      terraform -chdir="${TERRAFORM_PATH}" init > /dev/null
      terraform -chdir="${TERRAFORM_PATH}" workspace new "${APPLICATION}-${ENV}"
    else
      echo -en "MEMBER ACCOUNT IN CORE REPO      - ${APPLICATION}-${ENV} - ${GREEN}EXISTS${NORMAL}\n"
    fi

    # Creating MEMBER account state file for modernisation-platform-environments if it does not exist
    create_tmp_terraform_files environments-repo

    ACCOUNT_TYPE=$(jq -r '."account-type"' ${JSON_FILE})
    if [[ "${RETURN_CODE_MEMBER_REPO}" -ne 0 && "${ACCOUNT_TYPE}" == "member" ]]
    then
      echo -en "MEMBER ACCOUNT IN ENVIRONMENTS REPO - ${APPLICATION}-${ENV} - ${YELLOW}CREATING${NORMAL}\n"
      terraform -chdir="${TERRAFORM_PATH}" init > /dev/null
      terraform -chdir="${TERRAFORM_PATH}" workspace new "${APPLICATION}-${ENV}"
    else
      [[ ${ACCOUNT_TYPE} == "member" ]] && RESPONSE_TEXT="EXISTS" || RESPONSE_TEXT="CORE ACCOUNT - NOT REQUIRED IN MEMBER REPO"
      echo -en "MEMBER ACCOUNT IN ENVIRONMENTS REPO - ${APPLICATION}-${ENV} - ${GREEN}${RESPONSE_TEXT}${NORMAL}\n"
    fi
  done
done
}

main() {
# set friendly Parameter names
REQUEST_VALUE="${1}"  # this value can equal (bootstrap, all-environments or an application name)

# Set root path to repository
git_dir="$( git rev-parse --show-toplevel )"

# Determine workspace build type
case "${REQUEST_VALUE}" in
all-environments)
  iterate_environments_member "*"
  ;;
bootstrap)
  iterate_environments_bootstrap "delegate-access"
  iterate_environments_bootstrap "secure-baselines"
  iterate_environments_bootstrap "single-sign-on"
  iterate_environments_bootstrap "member-bootstrap"
  ;;
*)
  # This must be an individual application, check if json file exists for it
  if [ -f ${git_dir}/environments/${REQUEST_VALUE}.json ]
  then
    iterate_environments_member "${REQUEST_VALUE}"
  else
    echo "ERROR: Incorrect Parameter received"
    exit 1
  fi
  ;;
esac
}

# set friendly Parameter names
REQUEST_VALUE="${1}"

# setup colours for output
NORMAL="\001\033[0;0m\002"
YELLOW="\001\033[1;33m\002"
GREEN="\001\033[1;32m\002"

# call main function
main "${REQUEST_VALUE}"
