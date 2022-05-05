#!/bin/bash

set -euo pipefail

dependabot_file=.github/dependabot.yml

# Get a list of Terraform folders
all_tf_folders=`find . -type f -name '*.tf' | sed 's#/[^/]*$##' | sed 's/.\///'| sort | uniq`
all_env_test_folders=`find . -type f -name 'go.mod' | sed 's#/[^/]*$##' | sed 's/.\///'| sort | uniq`
echo
echo "All TF folders"
echo $all_tf_folders
echo
echo "All environment test folders"
echo $all_env_test_folders

echo "Writing dependabot.yml file"
# Creates a dependabot file to avoid having to manually add each new TF folder or go.mod file
# Add any additional fixed entries in this top section
  cat > $dependabot_file << EOL
# This file is auto-generated here, do not manually amend. 
# https://github.com/ministryofjustice/modernisation-platform/blob/main/scripts/generate-dependabot.sh

version: 2

updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
  # Dependabot doesn't currently support wildcard or multiple directory declarations within
  # a dependabot configuration, so we need to add all directories individually
  # See: github.com/dependabot/dependabot-core/issues/2178
EOL

for folder in $all_tf_folders
do
echo "Generating entry for ${folder}"
echo "  - package-ecosystem: \"terraform\"" >> $dependabot_file
echo "    directory: \"/${folder}\"" >> $dependabot_file
echo "    schedule:" >> $dependabot_file
echo "      interval: \"daily\"" >> $dependabot_file
done

for folder in $all_env_test_folders
do
echo "Generating entry for ${folder}"
echo "  - package-ecosystem: \"gomod\"" >> $dependabot_file
echo "    directory: \"/${folder}\"" >> $dependabot_file
echo "    schedule:" >> $dependabot_file
echo "      interval: \"daily\"" >> $dependabot_file
done