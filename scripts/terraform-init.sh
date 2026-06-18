#!/bin/bash

set -e

# This script runs terraform init with input set to false, no color outputs, and backend-config, suitable for running as part of a CI/CD pipeline.
# You need to pass through a Terraform directory as an argument, e.g.
# bash terraform-init.sh terraform/environments

state_kms_key_id() {
  if [ -n "${TERRAFORM_STATE_KMS_KEY_ID:-}" ]; then
    echo "${TERRAFORM_STATE_KMS_KEY_ID}"
    return
  fi

  local account_id="${MODERNISATION_PLATFORM_ACCOUNT_ID:-${MODERNISATION_PLATFORM_ACCOUNT_NUMBER:-}}"

  if [ -z "${account_id}" ] && [ -n "${ENVIRONMENT_MANAGEMENT:-}" ] && command -v jq >/dev/null 2>&1; then
    account_id=$(jq -r -e '.modernisation_platform_account_id // empty' <<< "${ENVIRONMENT_MANAGEMENT}" 2>/dev/null || true)
  fi

  if [ -z "${account_id}" ] && command -v aws >/dev/null 2>&1; then
    account_id=$(aws ssm get-parameter \
      --name modernisation_platform_account_id \
      --with-decryption \
      --region eu-west-2 \
      --query Parameter.Value \
      --output text 2>/dev/null || true)
  fi

  if [ -z "${account_id}" ] || ! [[ "${account_id}" =~ ^[0-9]{12}$ ]]; then
    echo "Unable to resolve Modernisation Platform account ID for Terraform state KMS backend config." >&2
    echo "Set TERRAFORM_STATE_KMS_KEY_ID, MODERNISATION_PLATFORM_ACCOUNT_ID, MODERNISATION_PLATFORM_ACCOUNT_NUMBER, or ENVIRONMENT_MANAGEMENT." >&2
    exit 1
  fi

  echo "arn:aws:kms:eu-west-2:${account_id}:alias/s3-state-bucket"
}

if [ -z "$1" ]; then
  echo "Unsure where to run terraform, exiting"
  exit 1
else
  kms_key_id="$(state_kms_key_id)"
  terraform -chdir="$1" init -input=false -no-color -backend-config="kms_key_id=${kms_key_id}"
fi
