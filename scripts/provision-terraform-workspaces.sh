#!/bin/bash

# This script provisions Terraform workspaces. It does not run terraform plan or terraform apply.
#
# You need to pass through an argument to this script:
#
# bootstrap (`sh scripts/provision-terraform-workspaces.sh bootstrap`)
# Using the `bootstrap` argument will create Terraform workspaces for all applications and their environments
# within terraform/environments/bootstrap/* subdirectories.
# Use case: to create Terraform workspaces for bootstrap steps.
#
# all-environments (`sh scripts/provision-terraform-workspaces.sh all-environments`)
# Using the `all-environments` argument will create Terraform workspaces for all applications and their environments
# within terraform/environments/${application_name} subdirectories.
# Use case: to ensure all applications workspaces are configured.
#
# any application name (e.g `sh scripts/provision-terraform-workspaces.sh core-vpc`)
# Passing through an application name will create Terraform workspaces for an application's environments,
# within their terraform/environments/${application_name} subdirectory.
# Use case: to ensure a single applications workspaces are configured (e.g. if a new environment is created).

TMP_DIR=tmp/terraform-workspaces
TF_ENV_DIR=terraform/environments

refresh_tmp_location() {
  if [ -d "tmp/" ]; then
    rm -r tmp/
  fi

  mkdir -p $TMP_DIR/local
  mkdir -p $TMP_DIR/remote
}

get_local_definitions() {
  for file in environments/*.json; do
    filename=$(basename "$file" .json)
    cat "$file" | jq -r --arg filename "$filename" '$filename + "-" + .environments[].name' >> $TMP_DIR/local/"$filename".txt
  done
}

get_remote_terraform_workspaces() {
  directory_basename=$(basename "$1")
  terraform -chdir="$1" init > /dev/null
  terraform -chdir="$1" workspace list > $TMP_DIR/remote/"$directory_basename".txt
}

fix_workspace_syntax() {
  for file in "$TMP_DIR"/*/*.txt; do
    # cleanup file syntax (removes preceding asterisks (*), spaces, the "default" terraform workspace, new lines, duplicate lines)
    sed -e "s/*//" -e "s/^[[:space:]]*//" -e "/default/d" -e "/^$/d" "$file" | sort -u -o "$file"
  done
}

create_missing_remote_workspaces() {

  echo "Comparing workspaces for: $2"

  directory_basename=$(basename "$2")

  if [ "$1" = "bootstrap" ]; then
    # To create Terraform workspaces for bootstrapping, we need all of the
    # environments listed together

    cat $TMP_DIR/local/*.txt | sort | uniq > $TMP_DIR/all.txt
    local_filename=all
  else
    local_filename="local/$directory_basename"
  fi

  local_workspaces="$TMP_DIR/$local_filename.txt"
  remote_workspaces="$TMP_DIR/remote/$directory_basename.txt"

  # Compare local with remote workspaces, and create missing ones
  for workspace in $(comm -2 -3 "$local_workspaces" "$remote_workspaces"); do
    echo "---------"
    echo "CREATING $workspace missing for $2"
    terraform -chdir="$2" workspace new "$workspace"
    echo "FINISHED creating terraform workspaces in $directory"
  done


}

main () {
  if [ -z "$1" ]; then
    echo "Type missing: must be \"bootstrap\", \"all-environments\", or an application name e.g. \"core-vpc\""
  else

    refresh_tmp_location &&
    get_local_definitions &&

    if [ "$1" = "bootstrap" ]; then

      # Get all bootstrappable directories in TF_ENV_DIR/bootstrap/*
      directories=$(find "$TF_ENV_DIR/bootstrap" -mindepth 1 -maxdepth 1 -type d)

    elif [ "$1" = "all-environments" ]; then

      # Get all directories in TF_ENV_DIR/*, minus /bootstrap and .terraform
      directories=$(find "$TF_ENV_DIR" -mindepth 1 -maxdepth 1 -type d -not \( -name ".terraform" -o -name "bootstrap" \))

    elif [ -d "$TF_ENV_DIR/$1" ]; then

      # Get directory for singular application
      directories="$TF_ENV_DIR/$1"

    else
      echo "Directory for \"$1\" does not exist"
      exit 1
    fi

    for directory in $directories; do

      get_remote_terraform_workspaces "$directory" &&
      fix_workspace_syntax &&
      create_missing_remote_workspaces "$1" "$directory"

    done

  fi
}

main "$1"
