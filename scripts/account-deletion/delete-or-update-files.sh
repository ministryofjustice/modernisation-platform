#!/bin/bash

source config.txt

# Git setup for MP repository
echo "Creating a branch in the MP repository"
timestamp=$(date +%s)
git checkout -b "delete-$APPLICATION_NAME-environments-$timestamp"

for workspace in "${WORKSPACES[@]}"; do
    # Delete the environment from the application.json file
    cd $USER_MP_DIR/environments
    echo "Deleting $workspace from $APPLICATION_NAME.json"
    jq "del(.environments[] | select(.name == \"$workspace\"))" $APPLICATION_NAME.json > $APPLICATION_NAME.tmp
    mv $APPLICATION_NAME.tmp $APPLICATION_NAME.json

    # Delete the environment from environments-networks.json files
    business_unit=$(jq -r '.tags."business-unit"' $APPLICATION_NAME.json | tr "[:upper:]" "[:lower:]")
    account=$APPLICATION_NAME-$workspace
    echo "Removing all references to $account in $business_unit-$workspace.json"
    cd $USER_MP_DIR/environments-networks
    jq ".cidr."subnet_sets".general.accounts |= map(select(. != \"$account\"))" $business_unit-$workspace.json > $business_unit-$workspace.tmp
    mv $business_unit-$workspace.tmp $business_unit-$workspace.json

    # Delete environment from opa networking test policies
    echo "Removing all references to $account in networking/expected.rego"
    cd $USER_MP_DIR/policies/networking
    sed -i '' -e "/$account/d" expected.rego
done

# If all environments are being deleted, delete the relevant files
if [[ $COMPLETE_DELETION = "yes" ]]; then

    # Delete environments/*.json file 
    echo "Deleting $APPLICATION_NAME.json in $USER_MP_DIR/environments/"
    rm $USER_MP_DIR/environments/$APPLICATION_NAME.json

    # Delete environment from opa environment test policies
    echo "Removing all references to $APPLICATION_NAME in $USER_MP_DIR/policies/environments/expected.rego"
    cd $USER_MP_DIR/policies/environments
    sed -i '' -e "/$APPLICATION_NAME/d" expected.rego

    # Git setup for MP Environments repository
    echo "Creating a branch in the MP Environments repository"
    timestamp=$(date +%s)
    git -C $USER_MPE_DIR checkout -b "delete-$APPLICATION_NAME-$timestamp"

    echo "Deleting $USER_MPE_DIR/terraform/environments/$APPLICATION_NAME"
    rm -rf $USER_MPE_DIR/terraform/environments/$APPLICATION_NAME

    echo "Deleting $USER_MPE_DIR/.github/workflows/$APPLICATION_NAME.yml"
    rm $USER_MPE_DIR/.github/workflows/$APPLICATION_NAME.yml
fi

echo "----------------------------------------------------------------"
echo -e "This script has created a branch with the necessary files changes in the MP repo (and where applicable in the MP Environments repo). \n
AFTER you have finished the manual steps to delete the account/s fully, you will need to raise a PR to merge your changes into main to complete the process."