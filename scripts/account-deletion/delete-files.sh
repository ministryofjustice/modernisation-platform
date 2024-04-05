#!/bin/bash
source config.txt

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
echo -e "This script has created a branch with the necessary files changes. \n
AFTER you have finished the manual steps to delete the account/s fully, you will need to raise a PR to merge your changes into main to complete the process."