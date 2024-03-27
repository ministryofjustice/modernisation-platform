#!/bin/bash
source config.txt

# If all environments are being deleted, delete the relevant files
if [[ $COMPLETE_DELETION = "yes" ]]; then

    echo "Deleting $APPLICATION_NAME.json in the MP repository"
    rm $USER_MP_DIR/environments/$APPLICATION_NAME.json

    # Git setup for MP Environments repository
    echo "Creating a branch in the MP Environments repository"
    timestamp=$(date +%s)
    git -C $USER_MPE_DIR checkout -b "delete-$APPLICATION_NAME-$timestamp"

    echo "Deleting terraform/environments/$APPLICATION_NAME in the MP Environments repository"
    rm -rf $USER_MPE_DIR/terraform/environments/$APPLICATION_NAME

    echo "Deleting .github/workflows/$APPLICATION_NAME.yml in the MP Environments repository"
    rm $USER_MPE_DIR/.github/workflows/$APPLICATION_NAME.yml
fi