#!/bin/bash

prepare_terraform () {
  # We can buffer output (stdout and stderr) unless terraform exits with a non-zero code, so we don't unneccessarily
  # log the output of these commands in our CI/CD runner
  echo "Running terraform init for $called_function"
  output=$(terraform init -input=false 2>&1) || (echo "$output" && false)
  echo "Running terraform validate for $called_function"
  output=$(terraform validate -no-color 2>&1) || (echo "$output" && false)
}

run_terraform_plan () {
  # We can buffer output (stdout and stderr) unless terraform exits with a non-zero code, so we don't unneccessarily
  # log the output of these commands in our CI/CD runner
  echo "Running terraform refresh for $called_function (this may take a while)"
  output=$(terraform refresh 2>&1) || (echo $$output && false)
  echo "Running terraform plan for $called_function (this may take a while)"
  terraform plan -refresh=false -input=false
}

get_remote_workspaces() {
  cd terraform/environments/bootstrap || exit &&
  called_function="prepare_terraform, in the bootstrap directory"
  prepare_terraform &&
  terraform workspace select default
  terraform workspace list > ../../../tmp/bootstrap-workspaces.tmp
  cat ../../../tmp/bootstrap-workspaces.tmp | grep "\S" | grep -v "default" | tr -d "* " | tee ../../../tmp/bootstrap-workspaces.tmp
  cd ../../..
}

loop_through_workspaces_and_plan() {
  cd terraform/environments/bootstrap || exit &&
  while read -r line; do
    called_function="$line"
    terraform workspace select $line &&
    run_terraform_plan
  done < ../../../tmp/bootstrap-workspaces.tmp
  cd ../../..
}

main () {
  mkdir -p tmp/ &&
  get_remote_workspaces &&
  loop_through_workspaces_and_plan &&
  rm -r tmp/
}

main
