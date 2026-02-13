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

plan_output=""
plan_summary=""

if [ ! -z "$2" ]; then
  options="$2"
  plan_output=$(terraform -chdir="$1" plan -input=false -no-color "$options" | ./scripts/redact-output.sh)  # Capture full output
else
  plan_output=$(terraform -chdir="$1" plan -input=false -no-color | ./scripts/redact-output.sh) # Capture full output
fi


plan_summary=$(echo "$plan_output" | grep -E 'Plan:|No changes. Your infrastructure matches the configuration.' || true)  # Extract summary from full output

if [ -z "$plan_summary" ]; then # If summary only contains "Changes to Outputs:"
  plan_summary="$(
    echo "$plan_output" | awk '
      /^Changes to Outputs:$/ { inblock=1; print; next }
      inblock && NF==0 { exit }
      inblock && $1 ~ /^[~+-]/ { print }
    '
  )"
fi

if tty -s; then
    echo "$plan_output" | tee /dev/tty    # Output full redacted plan to terminal if available
else
    echo "$plan_output"                   # Output full redacted plan to stdout (GitHub Actions logs)
fi

echo "summary<<EOF" >> $GITHUB_OUTPUT
echo "$plan_summary" >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT