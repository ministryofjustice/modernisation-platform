#!/bin/bash

# Enable error handling
set -e
set -o pipefail

# Set S3 bucket and AWS region
S3_BUCKET="modernisation-platform-terraform-state"

git_dir="$(git rev-parse --show-toplevel)"
TERRAFORM_PATH="${git_dir}/tmp"
mkdir -p "${TERRAFORM_PATH}"

# Check if Terraform state file exists in S3
state_file_exists() {
    local key="$1"
    aws s3api head-object --bucket ${S3_BUCKET} --key "${key}" > /dev/null 2>&1
}

# Create temporary Terraform files
setup_terraform_files() {
    local application_name="$1" component="$2"
    echo "Setting up Terraform files for ${application_name}/${component}"
    rm -rf "${TERRAFORM_PATH}" && mkdir -p "${TERRAFORM_PATH}"
    sed "s/\$application_name/${application_name}/g; s/\$component_name/${component}/g" "${git_dir}/terraform/templates/modernisation-platform-environments-components/platform_backend.tf" > "${TERRAFORM_PATH}/platform_backend.tf"
    cp "${git_dir}/terraform/templates/modernisation-platform/providers.tf" "${TERRAFORM_PATH}/providers.tf"
    cp "${git_dir}/terraform/templates/modernisation-platform/secrets.tf" "${TERRAFORM_PATH}/secrets.tf"
    cp "${git_dir}/terraform/templates/modernisation-platform/versions.tf" "${TERRAFORM_PATH}/versions.tf"
}

# Create Terraform workspace
create_workspace() {
    local workspace="$1"
    echo "Creating Terraform workspace: ${workspace}"
    terraform -chdir="${TERRAFORM_PATH}" init > /dev/null 2>&1
    terraform -chdir="${TERRAFORM_PATH}" workspace new "${workspace}" > /dev/null 2>&1
}

# Process JSON files in the directory
process_json() {
    for JSON_FILE in ${git_dir}/environments/*.json
    do
        application_name=$(basename "${JSON_FILE}" .json)
        echo "Processing ${JSON_FILE}"

        # Check if "components" exists and has at least one element
        component_count=$(jq -r '.components | length' "${JSON_FILE}")
        if [[ "$component_count" -eq 0 ]]; then
            echo "Skipping ${JSON_FILE}: 'components' attribute is empty"
            continue
        fi

        environments=$(jq -r '.environments[].name' "${JSON_FILE}")
        components=$(jq -r '.components[].name' "${JSON_FILE}")

        for env in ${environments}; do
            workspace_name="${application_name}-${env}"
            for component in ${components}; do
                state_path="environments/members/${application_name}/${component}/${application_name}-${env}/terraform.tfstate"
                if ! state_file_exists "${state_path}"; then
                    echo "State file missing: ${state_path}, workspace required."
                    setup_terraform_files "${application_name}" "${component}"
                    create_workspace "${workspace_name}"
                fi
            done
        done
    done
}

# Run the process
process_json
