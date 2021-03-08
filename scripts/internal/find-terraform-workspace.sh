#!/bin/bash

current_directory=$(pwd)

loop_directories() {
  echo "Starting a \`terraform workspace\` search for \`$1\` from $current_directory"
  for directory in $(find . -type d \( -name .terraform -o -name templates -o -name modules \) -prune -o -name '*.tf' -exec dirname {} \; | sort -u)
    do
      echo "" # add spacing around the messages
      echo "$(tput setaf 4)Searching for Terraform workspaces in $directory$(tput sgr0)"
      terraform -chdir="$directory" workspace select default
      terraform -chdir="$directory" workspace select "$1"
      echo "" # add spacing around the messages
      echo "$(tput setaf 4)Finished searching for Terraform workspaces in $directory$(tput sgr0)"
      echo "" # add spacing around the messages
  done
}

loop_directories $1
