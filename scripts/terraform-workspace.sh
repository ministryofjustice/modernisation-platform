#!/bin/bash

set -o pipefail
set -e

# This script runs terraform workspace with input set to false and no color outputs, suitable for running as part of a CI/CD pipeline.
# You need to pass through a Terraform directory as the first argument an an environment as the second argument, e.g.
# sh terraform-workspace.sh terraform/environments cooker-development

# This script pipes the output of terraform plan to ./scripts/redact-output.sh to redact sensitive things, such as AWS keys if they
# are exposed via terraform plan.

# Make redact-output.sh executable
chmod +x ./scripts/redact-output.sh

if [ -z "$1" ]; then
  echo "Unsure where to run terraform, exiting"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Unsure which workspace to select, exiting"
  exit 1
fi

if [ $# -ne 2 ]; then
  echo "Expected two arguments: <directory> <workspace>"
  exit 1
fi

echo "Setting directory to" "$1"
echo "Selecting workspace" "$2"

terraform -chdir="$1" workspace select "$2" -input=false -no-color | ./scripts/redact-output.sh
