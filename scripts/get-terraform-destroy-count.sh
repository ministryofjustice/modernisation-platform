
#!/bin/bash

set -o pipefail

# This script reads the terraform plan summary and gets the count of resources to be destroyed and sets it to the variable destroy_count.
# It also runs some checks to ensure that the values for the count and the threshold are valid.

# Checks that PLAN_DESTROY_CHECK is set. Without this the script will fail so we force an exit.
if [ -z "$plan_summary" ]; then
    echo "Plan Summary is not set"
    exit 1
fi

# This looks for the summary output for no changes & exits the script if found.
if echo "$plan_summary" | grep -q "No changes. Your infrastructure matches the configuration."; then
    echo "No changes. Your infrastructure matches the configuration."
    destroy_count=0
    destroy_notify=false
    exit 0
fi

destroy_count=$(echo "$plan_summary" | grep -oE 'Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy.' | awk '{print $8}')

destroy_notify=false

echo "destroy_threshold=$destroy_threshold"
echo "destroy_count=$destroy_count"

# These tests will force an exit of the script if the values are not valid as we don't want to proceed if invalid.
if ! [[ "$destroy_threshold" =~ ^[0-9]+$ ]]; then
    echo "Invalid destroy_threshold value: $destroy_threshold"
    exit 1
elif ! [[ "$destroy_count" =~ ^[0-9]+$ ]]; then
    echo "Invalid destroy_count value: $destroy_count"
    exit 1
fi

# These checks will print a warning if the destroy count is above the threshold. Useful for trouble-shooting.
if [ "$destroy_count" -gt "$destroy_threshold" ]; then
    echo "Warning: There are $destroy_count resources to be destroyed in this plan."
    destroy_notify=true
elif [ "$destroy_count" -gt 0 ]; then
    echo "There are $destroy_count resources to be destroyed, which is below the set threshold of $DESTROY_THRESHOLD."
else
    echo "No resources to be destroyed"
fi

echo "destroy_count=$destroy_count" >> $GITHUB_OUTPUT
echo "destroy_notify=$destroy_notify" >> $GITHUB_OUTPUT
