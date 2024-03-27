#!/bin/bash

source config.txt

cd $USER_MP_DIR/environments

# Git setup
echo "Creating a branch"
timestamp=$(date +%s)
git checkout -b "delete-$application_name-environments-$timestamp"

for workspace in $WORKSPACES do;
    # Delete the environment from the application.json file (or the whole file)
    if [[ $(echo "${#WORKSPACES[@]}") != 4 ]]; then
        echo "Deleting $workspace from $application_name.json"
        jq "del(.environments[] | select(.name == \"$workspace\"))" $application_name.json > $application_name.tmp
        mv $application_name.tmp $application_name.json
    else 
        echo "Deleting $application_name.json"
        rm $application_name.json
    fi

    # Delete the environment from environments-networks.json files
    business_unit=$(jq -r '.tags."business-unit"' $application_name.json | tr "[:upper:]" "[:lower:]")
    account=$application_name-$workspace
    echo "Removing all references to $account in $business_unit-$workspace.json"
    cd ../environments-networks
    jq ".cidr."subnet_sets".general.accounts |= map(select(. != \"$account\"))" $business_unit-$workspace.json > $business_unit-$workspace.tmp
    mv $business_unit-$workspace.tmp $business_unit-$workspace.json

    # Delete environment from opa test policies
    echo "Removing all references to $workspace in environments/expected.rego"
    cd ../policies/environments
    sed -i '' -e "/$application_name/d" expected.rego

    echo "Removing all references to $account in networking/expected.rego"
    cd ../networking
    sed -i '' -e "/$account/d" expected.rego
done