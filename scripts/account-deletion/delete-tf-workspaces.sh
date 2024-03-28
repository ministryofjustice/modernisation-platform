#!/bin/bash

echo "Dont forget to use your mod plat credentials before running this script"
echo "Please enter the application name you would like to kill"
read application_name
echo "Please enter the workspace you would like to kill"
read workspace

echo "You have selected,$application_name and $workspace! Lets gooo."

cd ../../modernisation-platform/terraform/environments/bootstrap/


# Check the exit status of the command
if [ $? -ne 0 ]; then
    echo "Are you running this in the scripts directory?"
    echo "Exiting the script."
    exit 1
fi

# Define the list of directories
directories=("delegate-access" "secure-baselines" "single-sign-on" "member-bootstrap")

for dir in "${directories[@]}"; do
    cd "$dir" || { echo "Failed to navigate to $dir"; exit 1; }
    terraform init > /dev/null 2>&1
    terraform workspace select default
    pwd
    echo "Here I will run terraform workspace delete -force $workspace"
    # Return to the original directory
    cd - > /dev/null
done
