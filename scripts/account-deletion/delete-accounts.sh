#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
log_file="$SCRIPT_DIR/execution_log.txt"

scripts=(
    "$SCRIPT_DIR/delete-tf-state.sh"
    "$SCRIPT_DIR/update-files.sh"
    "$SCRIPT_DIR/delete-tf-resources.sh"
    "$SCRIPT_DIR/delete-tf-workspaces.sh"
    "$SCRIPT_DIR/delete-files.sh"
)

# Check required programs are installed.
check_requirements() {
    local required_programs=("terraform" "jq")
    local missing=0

    for program in "${required_programs[@]}"; do
        if ! command -v "$program" &>/dev/null; then
            echo "Error: $program is not installed."
            missing=1
        fi
    done

    if [[ "$missing" -eq 1 ]]; then
        echo "Please install the missing programs and try again."
        exit 1
    fi

    echo "All required programs are installed."
}

# Execute a script and record its result.
execute_script() {
    local script_path="$1"
    local status

    printf '%s - Executing %s...\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$script_path" |
        tee -a "$log_file"

    # Execute without redirecting stdout or stderr to allow user interaction.
    if "$script_path"; then
        printf '%s - Success: %s completed successfully.\n' \
            "$(date '+%Y-%m-%d %H:%M:%S')" \
            "$script_path" |
            tee -a "$log_file"

        return 0
    else
        status=$?

        printf '%s - Error: %s failed with status %s.\n' \
            "$(date '+%Y-%m-%d %H:%M:%S')" \
            "$script_path" \
            "$status" |
            tee -a "$log_file"

        return "$status"
    fi
}

run_script_confirmation() {
    local response

    read -r -p "Do you want to continue? (y/n) " response
    [[ "$response" =~ ^[Yy]$ ]]
}

check_requirements

# Initialise or clear the log file.
: > "$log_file"

# Ensure the child scripts are executable.
chmod +x "${scripts[@]}"

printf '%s\n' \
    "Before you execute this script:" \
    "" \
    "* Be aware that some resources, such as S3 buckets, cannot be destroyed until you manually empty all objects and versions in them." \
    "" \
    "* Ensure that you have fetched the most recent updates in your local MP and MPE directories by executing a git pull command." \
    "" \
    "* Ensure that you have deleted all local .terraform directories and .terraform.lock.hcl files." \
    ""

if ! run_script_confirmation; then
    echo "Cancelling script run"
    exit 0
fi

printf '%s - Starting to execute scripts...\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" |
    tee -a "$log_file"

for script_path in "${scripts[@]}"; do
    if ! execute_script "$script_path"; then
        status=$?

        printf '%s - Stopping execution due to failure.\n' \
            "$(date '+%Y-%m-%d %H:%M:%S')" |
            tee -a "$log_file"

        exit "$status"
    fi
done

printf '%s - All scripts executed successfully.\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" |
    tee -a "$log_file"
