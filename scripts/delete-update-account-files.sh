#!/bin/bash

echo "Dont forget to use your mod plat credentials before running this script"
echo "Please enter the application name you would like to kill"
read application_name
echo "Please enter the workspace you would like to kill.
If you are removing all the environments for an application type 'all'"
read workspace

echo "You have selected,$application_name and $workspace! Lets gooo."

cd ../../modernisation-platform/environments

# Check the exit status of the command
if [ $? -ne 0 ]; then
    echo "Are you running this in the scripts directory?"
    echo "Exiting the script."
    exit 1
fi

# Git setup
echo "Pulling latest changes to origin/main"
git pull origin/main
echo "Creating a branch"
git checkout -b "delete-$application_name-$workspace"

# Delete the environment from the application.json file (or the whole file)
if [[ $workspace != "all" ]]; then
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