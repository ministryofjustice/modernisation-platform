#!/bin/bash

template_folder="./terraform/templates/modernisation-platform-environments"
environments_folder="../modernisation-platform-environments/terraform/environments"
token='$application_name'

for subfolder in "$environments_folder"/*/
do
  if [ -d "$subfolder" ]; then
    application_name=$(basename "$subfolder")
    echo "Copying files for $application_name"
    for file in "$template_folder"/platform_*
      do
        if [ -f "$file" ]; then
          filename=$(basename "$file")
          echo "    $filename"
          cp "$file" "$subfolder/$filename"
          sed -i '' "s/$token/$application_name/g" "$subfolder/$filename"
        fi
    done
  fi
done
