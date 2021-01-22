#!/bin/bash

basedir=terraform/environments
templates=(terraform/templates/*.tf)

provision_environment_directories() {
  for file in environments/*.json; do
    application_name=$(basename "$file" .json)
    directory=$basedir/$application_name

    if [ -d "$directory" ]; then
      # Do nothing if a directory already exists
      echo ""
      echo "Ignoring $directory, it already exists"
      echo ""
    else
      # Create the directory and copy files if it doesn't exist
      echo ""
      echo "Creating $directory"

      mkdir -p "$directory"
      copy_templates "$directory" "$application_name"

    fi
  done
}

copy_templates() {

  for file in "${templates[@]}"; do
    filename=$(basename "$file")
    echo "Copying $file to $1, replacing application_name with $application_name"
    sed "s/application_name/${application_name}/g" "$file" > "$1/$filename"
  done

  echo "Finished copying templates."
}

provision_environment_directories
