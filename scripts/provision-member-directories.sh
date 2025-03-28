#!/bin/bash

# To test the script locally, uncomment the following two lines
# core_repo_dir=.
# env_repo_dir=../modernisation-platform-environments

# To test the script locally, comment out the following two lines
core_repo_dir=core-repo
env_repo_dir=modernisation-platform-environments
basedir=$env_repo_dir/terraform/environments
networkdir=$core_repo_dir/environments-networks
templates=$core_repo_dir/terraform/templates/modernisation-platform-environments/*.*
component_templates=$core_repo_dir/terraform/templates/modernisation-platform-environments-components/*.*
isolated_templates=$core_repo_dir/terraform/templates/modernisation-platform-environments-isolated/*.*
environment_json_dir=$core_repo_dir/environments
codeowners_file=$env_repo_dir/.github/CODEOWNERS

provision_environment_directories() {
  # This reshapes the JSON for subnet sets to include the business unit, pulled from the filename; and the set name from the key of the object:
  # [
  #   {
  #     "subnet_sets": [
  #       {
  #         "cidr": "10.233.8.0/21",
  #         "accounts": [
  #           "nomis",
  #           "oasys",
  #         ],
  #         "set": "general",
  #         "business-unit": "hmpps"
  #       },
  #       {
  #         "cidr": "10.233.16.0/21",
  #         "accounts": [
  #           "delius"
  #         ],
  #         "set": "delius",
  #         "business-unit": "hmpps"
  #       }
  #     ]
  #   }...
  # ]
  networking_definitions=$(jq -n '[ inputs | { subnet_sets: .cidr.subnet_sets | to_entries | map_values(.value + { set: .key, "business-unit": input_filename | ltrimstr("'$core_repo_dir'/environments-networks/") | rtrimstr(".json") | split("-")[0] } ) } ]' "$networkdir"/*.json)

  for file in $environment_json_dir/*.json; do

    echo "This is file: $file"
    application_name=$(basename "$file" .json)
    echo "This is the application name: $application_name"
    account_type=$(jq -r '."account-type"' "$file")
    echo "This is a " $account_type " account"
    isolated_network=$(jq -r '."isolated-network"' "$file")
    echo "Isolated network: $isolated_network"
    directory=$basedir/$application_name
    echo "This is the directory: $directory"
    account_type=$(jq -r '."account-type"' ${environment_json_dir}/${application_name}.json)

    if [ -d $directory ] || [ "$account_type" != "member" ] || [ "$application_name" == "testing" ]; then
      # Do nothing if a directory already exists
      echo ""
      echo "Ignoring $directory, it already exists or is a core account or unrestricted account"
      echo ""
    else
      if [ "$isolated_network" = "true" ]; then
        # Create the directory and copy files if it doesn't exist
        echo ""
        echo "Creating $directory"

        mkdir -p "$directory"
        copy_isolated_templates "$directory" "$application_name"

        # Create workflow file
        echo "Creating workflow file"
        sed "s/\$application_name/$application_name/g" "$core_repo_dir/.github/workflows/templates/workflow-template.yml" > "$env_repo_dir/.github/workflows/$application_name.yml"
      else
        # Create the directory and copy files if it doesn't exist
        echo ""
        echo "Creating $directory"

        mkdir -p "$directory"
        copy_templates "$directory" "$application_name"

        # Create workflow file
        echo "Creating workflow file"
        sed "s/\$application_name/$application_name/g" "$core_repo_dir/.github/workflows/templates/workflow-template.yml" > "$env_repo_dir/.github/workflows/$application_name.yml"
      fi
    fi

    # This filters and reshapes networking_definitions to only include the business units and subnet sets for $APPLICATION_NAME
    # e.g. if hmpps-production.json and laa-production.json both contained subnet-sets that specified the account "core-sandbox",
    # and $APPLICATION_NAME was core-sandbox, it would output this:
    # [
    #   {
    #     "business-unit": "hmpps",
    #     "set": "general"
    #   },
    #   {
    #     "business-unit": "laa",
    #     "set": "general"
    #   }
    # ]

    # check if /environments-networks files exists for this application
    FILE_EXISTS=`jq --arg APPLICATION_NAME "$application_name" '.[].subnet_sets[] | select(.accounts[] | test("^" + $APPLICATION_NAME + "-"))' <<< "$networking_definitions"`
    if [[ ${FILE_EXISTS} ]]
    then
      # set up raw jq data that includes application name, business unit and subnet-set
      RAW_OUTPUT=`jq --arg APPLICATION_NAME "$application_name" 'limit(1;.[].subnet_sets[] | select(.accounts[] | test("^" + $APPLICATION_NAME + "-")) | { "business-unit": ."business-unit", "set": .set, "application": $APPLICATION_NAME } )' <<< "$networking_definitions"`
    else
      # set up raw jq data that includes application name, blank business unit and blank subnet-set
      RAW_OUTPUT=`jq -n --arg APPLICATION_NAME "$application_name" '{ "business-unit": "", "set": "", "application": $APPLICATION_NAME }'`
    fi
    # wrap raw json output with a header and store the result in the applications folder
    # Only populate networking.auto.tfvars.json if account type is not core
    if [ "$account_type" != "core" ]; then
      jq -rn --argjson DATA "${RAW_OUTPUT}" '{ networking: [ $DATA ] }' > "$directory"/networking.auto.tfvars.json
    fi

    # Handle components
    components=$(jq -r '.components | length' "$file")
    if [ "$components" -gt 0 ]; then
      echo "$application_name has components. Checking component directories."
      for component in $(jq -r '.components[].name' "$file"); do
        component_dir="$directory/$component"
        if [ -d "$component_dir" ]; then
          echo "Component directory $component_dir already exists. Skipping."
        else
          echo "Creating component directory: $component_dir"
          mkdir -p "$component_dir"
          cp "$directory/networking.auto.tfvars.json" "$component_dir/networking.auto.tfvars.json"
          copy_component_templates "$component_dir" "$application_name" "$component"
        fi
      done
    fi
  done
}

copy_isolated_templates() {
  for file in $isolated_templates; do
    filename=$(basename "$file")
    echo "Copying $file to $1, replacing application_name with $application_name"
    sed "s/\$application_name/${application_name}/g" "$file" > "$1/$filename"
  done
  echo "Finished copying isolated network templates."
}

copy_templates() {
  for file in $templates; do
    filename=$(basename "$file")
    echo "Copying $file to $1, replacing application_name with $application_name"
    sed "s/\$application_name/${application_name}/g" "$file" > "$1/$filename"
  done
  echo "Finished copying templates."
}

copy_component_templates() {
  local target_dir=$1
  local app_name=$2
  local component_name=$3
  for file in $component_templates; do
    filename=$(basename "$file")
    echo "Copying $file to $target_dir, replacing placeholders with $app_name and $component_name"
    sed -e "s/\$application_name/${app_name}/g" -e "s/\$component_name/${component_name}/g" "$file" > "$target_dir/$filename"
  done
  echo "Finished copying component templates."
}

generate_codeowners() {
echo "Writing codeowners file"
# Creates a codeowners file in the environments repo to ensure only teams can approve PRs referencing their code
  cat > $codeowners_file << EOL
# This file is auto-generated here, do not manually amend.
# https://github.com/ministryofjustice/modernisation-platform/blob/main/scripts/provision-member-directories.sh

* @ministryofjustice/modernisation-platform
EOL


  for file in $environment_json_dir/*.json; do
    application_name=$(basename "$file" .json)
    directory=/terraform/environments/$application_name
    account_type=$(jq -r '."account-type"' ${environment_json_dir}/${application_name}.json)
    codeowners=$(jq -r 'try (.codeowners[] | select(length > 0) | "@ministryofjustice/" + .)' ${environment_json_dir}/${application_name}.json | sort | uniq | tr '\n' ' ')
    sso_group_names=$(jq -r '.environments[].access[].sso_group_name | "@ministryofjustice/" + .' ${environment_json_dir}/${application_name}.json | sort | uniq | tr '\n' ' ')

    if [ "$account_type" = "member" ]; then
      # if codeowners array has been defined in the json file, use that
      if [ -n "$codeowners" ]; then
        echo "Adding $directory $codeowners@ministryofjustice/modernisation-platform  to codeowners"
        echo "$directory $codeowners@ministryofjustice/modernisation-platform" >> $codeowners_file
      # otherwise, use the sso_group_names array
      else
        echo "Adding $directory $sso_group_names@ministryofjustice/modernisation-platform to codeowners"
        echo "$directory $sso_group_names@ministryofjustice/modernisation-platform" >> $codeowners_file
      fi
      
      components=$(jq -r '.components | length' "$file")
        if [ "$components" -gt 0 ]; then
            for component in $(jq -r '.components[].name' "$file"); do
                component_directory="/terraform/environments/$application_name/$component"
                component_sso_group_name=$(jq -r --arg comp "$component" '.components[] | select(.name == $comp) | .sso_group_name' "$file")
                if [ -n "$component_sso_group_name" ] && [ "$component_sso_group_name" != "null" ]; then
                    echo "Adding $component_directory $component_sso_group_name @ministryofjustice/modernisation-platform to CODEOWNERS"
                    echo "$component_directory @ministryofjustice/$component_sso_group_name @ministryofjustice/modernisation-platform" >> $codeowners_file
                fi
            done
        fi
    fi
  done

  cat >> $codeowners_file << EOL
**/backend.tf @ministryofjustice/modernisation-platform
**/subnet_share.tf @ministryofjustice/modernisation-platform
**/networking.auto.tfvars.json @ministryofjustice/modernisation-platform
**/platform_*.tf @ministryofjustice/modernisation-platform
/terraform/modules/probation-webops @ministryofjustice/modernisation-platform @ministryofjustice/hmpps-migration
/terraform/modules
.devcontainer @ministryofjustice/devcontainer-community
EOL

}

provision_environment_directories
generate_codeowners