
#!/bin/bash

set -o pipefail
set -e

# This script reads the terraform plan summary and gets the count of resources to be destroyed and sets it to the variable destroy_count.
# It also runs some checks to ensure that the values for the count and the threshold are valid.

# Checks that PLAN_SUMMARY is set. Without this the script will fail so we force an exit.
if [ -z "$PLAN_SUMMARY" ]; then
    echo "PLAN_SUMMARY is not set"
    exit 1
fi

destroy_count=$(echo "$PLAN_SUMMARY" | grep -oE 'Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy.' | awk '{print $8}')

echo "destroy_threshold=$DESTROY_THRESHOLD"
echo "destroy_count=$destroy_count"

if echo "$PLAN_SUMMARY" | grep -q "No changes. Your infrastructure matches the configuration."; then
    echo "No changes. Your infrastructure matches the configuration."
    destroy_count=0
fi

# These tests will force an exit of the script if the values are not valid as we don't want to proceed if invalid.
if ! [[ "$DESTROY_THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Invalid DESTROY_THRESHOLD value: $DESTROY_THRESHOLD"
    exit 1
elif ! [[ "$destroy_count" =~ ^[0-9]+$ ]]; then
    echo "Invalid destroy_count value: $destroy_count"
    exit 1
fi

# These checks will print a warning if the destroy count is above the threshold. Useful for trouble-shooting.
if [ "$destroy_count" -gt "$DESTROY_THRESHOLD" ]; then
    echo "Warning: There are $destroy_count resources to be destroyed in this plan."
elif [ "$destroy_count" -gt 0 ]; then
    echo "There are $destroy_count resources to be destroyed, which is below the set threshold of $DESTROY_THRESHOLD."
else
    echo "No resources to be destroyed"
fi

echo "destroy_count=$destroy_count" >> $GITHUB_ENV