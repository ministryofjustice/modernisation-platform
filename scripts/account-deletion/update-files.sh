#!/bin/bash
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# shellcheck source=./config.txt
source "$SCRIPT_DIR/config.txt"

: "${APPLICATION_NAME:?APPLICATION_NAME must be set}"
: "${USER_MP_DIR:?USER_MP_DIR must be set}"

if [[ "$APPLICATION_NAME" == */* ]]; then
    echo "APPLICATION_NAME must not contain a slash: $APPLICATION_NAME" >&2
    exit 1
fi

# Git setup for MP repository.
echo "Creating a branch in the MP repository"
timestamp=$(date +%s)
git -C "$USER_MP_DIR" checkout -b "delete-$APPLICATION_NAME-environments-$timestamp"

for workspace in "${WORKSPACES[@]}"; do
    # Delete the environment from the application JSON file.
    cd -- "$USER_MP_DIR/environments"

    echo "Deleting $workspace from $APPLICATION_NAME.json"
    jq \
        --arg workspace "$workspace" \
        'del(.environments[] | select(.name == $workspace))' \
        "$APPLICATION_NAME.json" \
        > "$APPLICATION_NAME.tmp"

    mv -- "$APPLICATION_NAME.tmp" "$APPLICATION_NAME.json"

    # Delete the environment from environments-networks JSON files.
    business_unit=$(
        jq -r '.tags."business-unit"' "$APPLICATION_NAME.json" |
            tr '[:upper:]' '[:lower:]'
    )

    account="$APPLICATION_NAME-$workspace"

    echo "Removing all references to $account in $business_unit-$workspace.json"
    cd -- "$USER_MP_DIR/environments-networks"

    jq \
        --arg account "$account" \
        '.cidr.subnet_sets.general.accounts |= map(select(. != $account))' \
        "$business_unit-$workspace.json" \
        > "$business_unit-$workspace.tmp"

    mv -- \
        "$business_unit-$workspace.tmp" \
        "$business_unit-$workspace.json"

    # Delete environment from OPA networking test policies.
    echo "Removing all references to $account in networking/expected.rego"
    cd -- "$USER_MP_DIR/policies/networking"
    sed -i '' -e "/$account/d" expected.rego
done

echo "----------------------------------------------------------------"
printf '%s\n' \
    "This script has created a branch with the necessary file changes." \
    "" \
    "AFTER you have finished the manual steps to delete the account/s fully, you will need to raise a PR to merge your changes into main to complete the process."
