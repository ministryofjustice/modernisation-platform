#!/bin/bash

# This script outputs a JSON file containing:
# - The environment name
# - The email address from the "owner" field in "tags".
# If "owner" contains multiple colon-separated fields, it takes the second.

REPO=$GITHUB_REPO

# Directory containing the environment JSON files.
REMOTE_DIR="environments"
DIR="$GITHUB_WORKSPACE/$REMOTE_DIR"

NESTED_FIELD="tags.owner"

# Modernisation Platform environments to exclude from the JSON output.
MP_ENVS=("cooker" "example" "sprinkler" "testing")

if [[ ! ${PERIOD:-} =~ ^[1-9][0-9]*$ ]]; then
  echo "PERIOD must be a positive integer" >&2
  exit 1
fi

# Initialize an empty JSON array.
json_output="["

# Track whether this is the first item in the JSON array.
first=true

for file in "$DIR"/*.json; do
  if [ -f "$file" ]; then
    # Strip the '.json' suffix to leave the environment name.
    FILE_NAME=$(basename "$file" .json)

    # Check for an exact match against the excluded environments.
    is_mp_env=false
    for mp_env in "${MP_ENVS[@]}"; do
      if [[ "$FILE_NAME" == "$mp_env" ]]; then
        is_mp_env=true
        break
      fi
    done

    if [[ "$is_mp_env" == false ]]; then
      file_path="$REMOTE_DIR/$FILE_NAME.json"

      echo "$file_path"

      # Get the first commit of the file from the GitHub API.
      creation_date=$(curl -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/commits?path=$file_path&per_page=100" |
        jq -r '.[-1].commit.committer.date' |
        cut -d'T' -f1)

      echo "First commit date = $creation_date"

      formatted_date=$(date -d "$creation_date" '+%Y-%m-%d') || {
        echo "Invalid date format for Created Date"
        exit 1
      }

      current_date=$(date '+%Y-%m-%d')

      current_timestamp=$(date -d "$current_date" '+%s') || {
        echo "Invalid current date"
        exit 1
      }
      formatted_timestamp=$(date -d "$formatted_date" '+%s') || {
        echo "Invalid formatted date"
        exit 1
      }

      # Convert the difference to approximate months.
      diff_in_seconds=$((current_timestamp - formatted_timestamp))
      months_ago=$((diff_in_seconds / 2592000))

      echo "Commit date is $months_ago months old"
      echo " "
      echo " "
      echo "-------------------------------------"
      echo " "

      # Contact the owner when the approximate age is divisible by PERIOD.
      if (( months_ago % PERIOD == 0 )); then
        VALUE=$(jq -r ".$NESTED_FIELD" "$file" 2>/dev/null)

        if [ -n "$VALUE" ] && [ "$VALUE" != "null" ]; then
          PART_COUNT=$(echo "$VALUE" | awk -F: '{print NF}')

          if [ "$PART_COUNT" -gt 1 ]; then
            OWNER_PART=$(echo "$VALUE" | awk -F: '{print $2}' | xargs)
          else
            OWNER_PART=$(echo "$VALUE" | awk -F: '{print $1}' | xargs)
          fi

          if [ "$first" = false ]; then
            json_output+=","
          fi

          json_output+="
  {
    \"file\": \"$FILE_NAME\",
    \"owner\": \"$OWNER_PART\"
  }"

          first=false
        fi
      fi
    fi
  fi
done

json_output+="
]"

printf "%s" "$json_output" > output.json 2>/dev/null

# Stop the job when no environments were identified.
if [ "$first" = true ]; then
  echo "No files to be processed. Job will stop"
  printf "%s" "true" > stop.json 2>/dev/null
  exit 0
else
  echo "Environments identified as in scope"
fi

echo "Validating JSON Output"

if ! jq . output.json >/dev/null 2>&1; then
  echo "Error processing json."
  exit 1
else
  echo "Json output is valid"
  cat output.json
fi
