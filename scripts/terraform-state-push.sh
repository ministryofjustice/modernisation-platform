#!/bin/bash

set -o pipefail
set -e

# This script runs terraform apply with input set to false and no color outputs, suitable for running as part of a CI/CD pipeline.
# You need to pass through a Terraform directory as an argument, e.g.
# sh terraform-state-push.sh terraform/environments

# This script pipes the output of terraform state push to ./scripts/redact-output.sh to redact sensitive things, such as AWS keys if they
# are exposed via terraform apply.

# Make redact-output.sh executable
chmod +x ./scripts/redact-output.sh

if [ -z "$1" ]; then
  echo "Unsure where to run terraform, exiting"
  exit 1
else
  echo "Running 'terraform -chdir="$1" state push errored.tfstate'..."
  terraform -chdir="$1" state push errored.tfstate | ./scripts/redact-output.sh
  if [ ! -z "$2" ]; then
    options="$2"
    echo "Running 'terraform -chdir="$1" plan -input=false -no-color $options'..."
    terraform -chdir="$1" plan -input=false -no-color $options | ./scripts/redact-output.sh
  else
    echo "Running 'terraform -chdir="$1" plan -input=false -no-color'..."
    terraform -chdir="$1" plan -input=false -no-color | ./scripts/redact-output.sh
  fi
fi
