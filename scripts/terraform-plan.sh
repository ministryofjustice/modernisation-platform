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

tf_dir="$1"
options="${2:-}"

# Run Terraform plan and capture output and exit code
plan_file=$(mktemp)
if [ -n "$options" ]; then
  terraform -chdir="$tf_dir" plan -input=false -no-color $options | ./scripts/redact-output.sh > "$plan_file"
else
  terraform -chdir="$tf_dir" plan -input=false -no-color | ./scripts/redact-output.sh > "$plan_file" 
fi

exit_code=$?
plan_output=$(cat "$plan_file")
plan_summary=$(echo "$plan_output" | grep -E 'Plan:|No changes. Your infrastructure matches the configuration.')


if tty -s; then
  echo "$plan_output" | tee /dev/tty    # Output full redacted plan to terminal if available
else
  echo "$plan_output"                   # Output full redacted plan to stdout (GitHub Actions logs)    
fi

# Set summary for GitHub Actions
echo "summary<<EOF" >> "$GITHUB_OUTPUT"
echo "$plan_summary" >> "$GITHUB_OUTPUT"
echo "EOF" >> "$GITHUB_OUTPUT"

# Clean up
rm -f "$plan_file"

# Handle Terraform exit codes
if [ $exit_code -eq 1 ]; then
  echo "❌ Terraform plan failed."
  exit 1
elif [ $exit_code -eq 2 ]; then
  echo "✅ Terraform plan succeeded with changes."
  exit 0
else
  echo "✅ Terraform plan succeeded with no changes."
  exit 0
fi
