#!/bin/bash

template_folder="./terraform/templates/modernisation-platform-environments"
environments_folder="../modernisation-platform-environments/terraform/environments"
token='$application_name'

for subfolder in "$environments_folder"/*/
do
  if [ -d "$subfolder" ]; then
    application_name=$(basename "$subfolder")
    if [ "$application_name" == "sprinkler" ] || [ "$application_name" == "cooker" ]; then
      echo "Skipping sprinkler and cooker, update these manually"
    else
      echo "Copying files for $application_name"
      for file in "$template_folder"/platform_*
        do
          if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo "    $filename"
            if [ "$filename" == "platform_versions.tf" ]; then
              echo "Skipping $filename"
            else
              cp "$file" "$subfolder/$filename"
              sed -i '' "s/$token/$application_name/g" "$subfolder/$filename"
            fi
          fi
      done
    fi
  fi
done

echo
echo "NOTE: This script skips sprinkler and cooker, and all platform_versions.tf files"
