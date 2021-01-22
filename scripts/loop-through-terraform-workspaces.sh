#!/bin/bash

set -euo pipefail

TMP_DIR=tmp/terraform-workspaces

refresh_tmp_location() {
  if [ -d "tmp/" ]; then
    rm -r tmp/
  fi

  mkdir -p $TMP_DIR/remote
}

get_remote_terraform_workspaces() {
  echo "Getting remote workspaces"
  terraform -chdir="$1" workspace list > $TMP_DIR/remote/"$2".txt
  echo "Finished getting remote workspaces"
}

fix_workspace_syntax() {
  for file in "$TMP_DIR"/*/*.txt; do
    # Cleanup file syntax (removes preceding asterisks (*), spaces, the "default" terraform workspace, new lines, duplicate lines)
    sed -e "s/*//" -e "s/^[[:space:]]*//" -e "/default/d" -e "/^$/d" "$file" | sort -u -o "$file"
  done
}

run_terraform() {
  echo "Running terraform $3 across all workspaces in $1"

  # Loop over every workspace, and run Terraform plan
  while IFS= read -r line; do
    # Select workspace
    terraform -chdir="$1" workspace select "$line"

    # Run terraform plan
    if [ "$3" = "plan" ]; then
      ./scripts/terraform-plan.sh "$1"
    elif [ "$3" = "apply" ]; then
      ./scripts/terraform-apply.sh "$1"
    else
      echo "Unknown terraform command: $3"
    fi
  done < "$TMP_DIR"/remote/"$directory_basename".txt

  echo "Finished running terraform across all workspaces in $1"
}

main() {
  if [ -z "$1" ]; then
    echo "Directory missing: needs to be a directory in which there are Terraform files"
    exit 1
  elif [ -z "$2" ]; then
    echo "Unsure what Terraform command to run: must be plan or apply"
    exit 1
  else

    directory_basename=$(basename "$1")

    if [ -d "$1" ]; then

      refresh_tmp_location &&
      get_remote_terraform_workspaces "$1" "$directory_basename" &&
      fix_workspace_syntax &&
      run_terraform "$1" "$directory_basename" "$2"

    else
      echo "Directory for \"$1\" does not exist"
      exit 1
    fi

  fi
}

# Make terraform-init.sh executable
chmod +x ./scripts/terraform-init.sh

# Make terraform-plan.sh executable
chmod +x ./scripts/terraform-plan.sh

# Make terraform-apply.sh executable
chmod +x ./scripts/terraform-apply.sh

main "$1" "$2"
