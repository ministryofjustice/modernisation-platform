#!/bin/bash

set -e

# This script runs terraform init with input set to false and no color outputs, suitable for running as part of a CI/CD pipeline.
# You need to pass through a Terraform directory as an argument, e.g.
# sh terraform-init.sh terraform/environments

if [ -z "$1" ]; then
  echo "Unsure where to run terraform, exiting"
  exit 1
else
  terraform -chdir="$1" init -input=false -no-color
fi
