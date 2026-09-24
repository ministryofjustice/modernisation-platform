#!/bin/bash

set -o pipefail

# Read the Terraform plan summary and report the number of resources to destroy.
plan_summary="${plan_summary:-}"
destroy_threshold="${DESTROY_THRESHOLD:-${destroy_threshold:-}}"

if [ -z "$plan_summary" ]; then
    echo "Plan Summary is not set"
    exit 1
fi

# A plan with no changes has a destroy count of zero.
if echo "$plan_summary" |
    grep -Fq "No changes. Your infrastructure matches the configuration."; then
    echo "No changes. Your infrastructure matches the configuration."
    echo "destroy_count=0" >> "$GITHUB_OUTPUT"
    exit 0
fi

destroy_count=$(echo "$plan_summary" |
    grep -oE 'Plan: [0-9]+ to add, [0-9]+ to change, [0-9]+ to destroy\.' |
    awk '{print $8}')

echo "destroy_threshold=$destroy_threshold"
echo "destroy_count=$destroy_count"

# Stop if either value is invalid.
if ! [[ "$destroy_threshold" =~ ^[0-9]+$ ]]; then
    echo "Invalid destroy_threshold value: $destroy_threshold"
    exit 1
elif ! [[ "$destroy_count" =~ ^[0-9]+$ ]]; then
    echo "Invalid destroy_count value: $destroy_count"
    exit 1
fi

if [ "$destroy_count" -gt "$destroy_threshold" ]; then
    echo "Warning: There are $destroy_count resources to be destroyed in this plan."
elif [ "$destroy_count" -gt 0 ]; then
    echo "There are $destroy_count resources to be destroyed, which is below the set threshold of $destroy_threshold."
else
    echo "No resources to be destroyed"
fi

echo "destroy_count=$destroy_count" >> "$GITHUB_OUTPUT"
