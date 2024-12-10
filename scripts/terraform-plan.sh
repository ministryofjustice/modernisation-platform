#!/bin/bash

set -o pipefail
set -e

# This script runs terraform plan with input set to false and no color outputs, suitable for running as part of a CI/CD pipeline.
# You need to pass through a Terraform directory as an argument, e.g.
# sh terraform-plan.sh terraform/environments

# This script pipes the output of terraform plan to ./scripts/redact-output.sh to redact sensitive things, such as AWS keys if they
# are exposed via terraform plan.

# Make redact-output.sh executable
chmod +x ./scripts/redact-output.sh

if [ -z "$1" ]; then
  echo "Unsure where to run terraform, exiting"
  exit 1
fi

plan_summary=""

if [ ! -z "$2" ]; then
  options="$2"
  if tty -s; then # Check if a terminal is available
    plan_summary=$(terraform -chdir="$1" plan -input=false -no-color $options | tee /dev/tty | ./scripts/redact-output.sh | grep -E 'Plan:|No changes. Your infrastructure matches the configuration.')
  else
    plan_summary=$(terraform -chdir="$1" plan -input=false -no-color $options | ./scripts/redact-output.sh | grep -E 'Plan:|No changes. Your infrastructure matches the configuration.')
  fi
else
  if tty -s; then
    plan_summary=$(terraform -chdir="$1" plan -input=false -no-color | tee /dev/tty | ./scripts/redact-output.sh | grep -E 'Plan:|No changes. Your infrastructure matches the configuration.')
  else
    plan_summary=$(terraform -chdir="$1" plan -input=false -no-color | ./scripts/redact-output.sh | grep -E 'Plan:|No changes. Your infrastructure matches the configuration.')
  fi
fi

echo "summary<<EOF" >> $GITHUB_OUTPUT
echo "$plan_summary" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT

