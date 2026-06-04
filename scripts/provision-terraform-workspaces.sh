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

# List all state files once
aws s3api list-objects-v2 --bucket modernisation-platform-terraform-state --prefix "environments/bootstrap/${BOOTSTRAP_TYPE}/" --query 'Contents[].Key' --output text | tr -s '[:space:]' '\n' > ${STATE_CACHE_DIR}/bootstrap_state_files.txt

# Loop through each application json file
for JSON_FILE in ${git_dir}/environments/*.json; do
  APPLICATION=`basename "${JSON_FILE}" .json`

  for ENV in $(jq -r --arg FILENAME "${APPLICATION}" '.environments[].name' "${JSON_FILE}"); do
      STATE_FILE="environments/bootstrap/${BOOTSTRAP_TYPE}/${APPLICATION}-${ENV}/terraform.tfstate"
      
      if grep -qFx "${STATE_FILE}" ${STATE_CACHE_DIR}/bootstrap_state_files.txt; then
        echo -en "BOOTSTRAP - ${BOOTSTRAP_TYPE} - ${APPLICATION}-${ENV} - ${GREEN}EXISTS${NORMAL}\n"
      else
        TERRAFORM_PATH="${git_dir}/terraform/environments/bootstrap/${BOOTSTRAP_TYPE}"
        echo -en "BOOTSTRAP - ${BOOTSTRAP_TYPE} - ${APPLICATION}-${ENV} - ${YELLOW}CREATING${NORMAL}\n"
        terraform -chdir="${TERRAFORM_PATH}" init > /dev/null
        terraform -chdir="${TERRAFORM_PATH}" workspace new "${APPLICATION}-${ENV}"
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
    sed "s/\$application_name/${APPLICATION}/g" "${git_dir}/terraform/templates/modernisation-platform/backend.tf" > "${git_dir}/tmp/backend.tf" 
  fi
  cp "${git_dir}/terraform/templates/modernisation-platform/providers.tf" "${git_dir}/tmp/providers.tf"
  cp "${git_dir}/terraform/templates/modernisation-platform/secrets.tf" "${git_dir}/tmp/secrets.tf"
  cp "${git_dir}/terraform/templates/modernisation-platform/versions.tf" "${git_dir}/tmp/versions.tf"
}

iterate_environments_member() {
# set friendly Parameter names
ENVIRONMENT_TYPE="${1}"  # this value can equal (* or an application name)

# Loop through each application json file
# List all state files with clean formatting
aws s3api list-objects-v2 --bucket modernisation-platform-terraform-state --prefix "environments/accounts/" --query 'Contents[].Key' --output text | tr -s '[:space:]' '\n' > ${STATE_CACHE_DIR}/core_state_files.txt
aws s3api list-objects-v2 --bucket modernisation-platform-terraform-state --prefix "environments/members/" --query 'Contents[].Key' --output text | tr -s '[:space:]' '\n' > ${STATE_CACHE_DIR}/member_state_files.txt

for JSON_FILE in ${git_dir}/environments/${ENVIRONMENT_TYPE}.json; do
  APPLICATION=$(basename "${JSON_FILE}" .json)
  ACCOUNT_TYPE=$(jq -r '."account-type"' "${JSON_FILE}")

  for ENV in $(jq -r --arg FILENAME "${APPLICATION}" '.environments[].name' "${JSON_FILE}"); do
    CORE_STATE_FILE="environments/accounts/${APPLICATION}/${APPLICATION}-${ENV}/terraform.tfstate"
    MEMBER_STATE_FILE="environments/members/${APPLICATION}/${APPLICATION}-${ENV}/terraform.tfstate"

    create_tmp_terraform_files

    # Core repo check
    if grep -qFx "${CORE_STATE_FILE}" ${STATE_CACHE_DIR}/core_state_files.txt; then
      echo -en "MEMBER ACCOUNT IN CORE REPO      - ${APPLICATION}-${ENV} - ${GREEN}EXISTS${NORMAL}\n"
    else
      TERRAFORM_PATH="${git_dir}/tmp"
      echo -en "MEMBER ACCOUNT IN CORE REPO      - ${APPLICATION}-${ENV} - ${YELLOW}CREATING${NORMAL}\n"
      terraform -chdir="${TERRAFORM_PATH}" init > /dev/null
      terraform -chdir="${TERRAFORM_PATH}" workspace new "${APPLICATION}-${ENV}"
    fi

    # Member repo check
    create_tmp_terraform_files environments-repo
      
    if grep -qFx "${MEMBER_STATE_FILE}" ${STATE_CACHE_DIR}/member_state_files.txt; then
      [[ ${ACCOUNT_TYPE} == "member" ]] && RESPONSE_TEXT="EXISTS" || RESPONSE_TEXT="CORE ACCOUNT - NOT REQUIRED IN MEMBER REPO"
      echo -en "MEMBER ACCOUNT IN ENVIRONMENTS REPO - ${APPLICATION}-${ENV} - ${GREEN}${RESPONSE_TEXT}${NORMAL}\n"
    elif [[ "${ACCOUNT_TYPE}" == "member" ]]; then
      TERRAFORM_PATH="${git_dir}/tmp"
      echo -en "MEMBER ACCOUNT IN ENVIRONMENTS REPO - ${APPLICATION}-${ENV} - ${YELLOW}CREATING${NORMAL}\n"
      terraform -chdir="${TERRAFORM_PATH}" init > /dev/null
      terraform -chdir="${TERRAFORM_PATH}" workspace new "${APPLICATION}-${ENV}"
    fi
  done
done
}

setup_directories() {
  # Create state cache directory if it doesn't exist
  if [ ! -d "${STATE_CACHE_DIR}" ]; then
      mkdir -p "${STATE_CACHE_DIR}"
  fi
}

cleanup() {
  # Only clean up state cache if it exists
  if [ -d "${STATE_CACHE_DIR}" ]; then
      rm -rf "${STATE_CACHE_DIR}"
  fi
}

main() {
# set friendly Parameter names
REQUEST_VALUE="${1}"  # this value can equal (bootstrap, all-environments or an application name)

# Set root path to repository
git_dir="$( git rev-parse --show-toplevel )"

STATE_CACHE_DIR="${git_dir}/.state_cache"

# Setup directories once at the start
setup_directories
trap cleanup EXIT

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
