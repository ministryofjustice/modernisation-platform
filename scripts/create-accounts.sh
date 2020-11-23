#!/bin/bash

run_terraform () {
  # We can buffer output (stdout and stderr) unless terraform exits with a non-zero code, so we don't unneccessarily
  # log the output of these commands in our CI/CD runner
  echo "Running terraform init for $called_function"
  output=$(terraform init -input=false 2>&1) || (echo "$output" && false)
  echo "Running terraform validate for $called_function"
  output=$(terraform validate -no-color 2>&1) || (echo "$output" && false)
  echo "Running terraform refresh for $called_function (this may take a while)"
  output=$(terraform refresh 2>&1) || (echo $$output && false)
  echo "Running terraform plan for $called_function (this may take a while)"
  output=$(terraform plan -refresh=false -input=false -no-color 2>&1) || (echo "$output" && false)
  echo "Running terraform apply for $called_function (this may take a while)"
  output=$(terraform apply -refresh=false -auto-approve 2>&1) || (echo "$output" && false)
}

create_accounts () {
  called_function="create_accounts"
  cd terraform/environments || exit
  run_terraform
  cd ../.. || exit
}

get_all_local_environment_definitions () {
  cat environments/*.json | jq -r '. | .name + "-" + .environments[]' > tmp/local-environments.tmp
}

get_all_remote_workspace_definitions () {
  cd terraform/environments/bootstrap || exit
  output=$(terraform init -input=false 2>&1) || (echo "$output" && false)
  terraform workspace list > ../../../tmp/remote-workspaces.tmp
  cat ../../../tmp/remote-workspaces.tmp | grep "\S" | grep -v "default" | tr -d "* " | tee ../../../tmp/remote-workspaces.tmp
  cd ../../.. || exit
}

compare_local_and_remote_definitions () {
  sort tmp/remote-workspaces.tmp -o tmp/remote-workspaces.tmp
  sort tmp/local-environments.tmp -o tmp/local-environments.tmp
  grep -xvFf tmp/remote-workspaces.tmp tmp/local-environments.tmp > tmp/remote-workspaces-missing.tmp
}

create_missing_remote_workspaces () {
  cd terraform/environments/bootstrap || exit
  while read -r line; do
    called_function="create_missing_remote_workspaces in workspace $line"
    output=$(terraform workspace select default) || (echo "$output" && false)
    output=$(terraform workspace new "$line") || (echo "$output" && false)
    output=$(terraform workspace select "$line") || (echo "$output" && false)
    run_terraform
  done < ../../../tmp/remote-workspaces-missing.tmp
  cd ../../.. || exit
}

main () {
  mkdir -p tmp/
  create_accounts &&
  get_all_local_environment_definitions &&
  get_all_remote_workspace_definitions &&
  compare_local_and_remote_definitions &&
  create_missing_remote_workspaces &&
  rm -r tmp/
}

main
