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

main () {
  mkdir -p tmp/
  create_accounts
  rm -rf tmp/
}

main
