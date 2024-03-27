#!/bin/bash

source config.txt

cd $USER_MP_DIR/environments

# Git setup
echo "Creating a branch in the MP repository"
timestamp=$(date +%s)
git checkout -b "delete-$APPLICATION_NAME-environments-$timestamp"

for workspace in $WORKSPACES do;
    # Delete the environment from the application.json file
    echo "Deleting $workspace from $APPLICATION_NAME.json"
    jq "del(.environments[] | select(.name == \"$workspace\"))" $APPLICATION_NAME.json > $APPLICATION_NAME.tmp
    mv $APPLICATION_NAME.tmp $APPLICATION_NAME.json

    # Delete the environment from environments-networks.json files
    business_unit=$(jq -r '.tags."business-unit"' $APPLICATION_NAME.json | tr "[:upper:]" "[:lower:]")
    account=$APPLICATION_NAME-$workspace
    echo "Removing all references to $account in $business_unit-$workspace.json"
    cd ../environments-networks
    jq ".cidr."subnet_sets".general.accounts |= map(select(. != \"$account\"))" $business_unit-$workspace.json > $business_unit-$workspace.tmp
    mv $business_unit-$workspace.tmp $business_unit-$workspace.json

    # Delete environment from opa test policies
    echo "Removing all references to $workspace in environments/expected.rego"
    cd ../policies/environments
    sed -i '' -e "/$APPLICATION_NAME/d" expected.rego

    echo "Removing all references to $account in networking/expected.rego"
    cd ../networking
    sed -i '' -e "/$account/d" expected.rego
done