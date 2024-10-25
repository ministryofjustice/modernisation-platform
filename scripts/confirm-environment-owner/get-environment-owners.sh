#!/bin/bash

# This script outputs a json file containing:
# - The environment name
# - The email address of the "owner" field in "tags".
# Note that it assumes that if multiple fields in "owner" it will take the 2nd field and delimit using ":"

# The repository
REPO=$GITHUB_REPO

# Directory containing the environment JSON files. Local and remote dirs.
REMOTE_DIR="environments"

DIR="$GITHUB_WORKSPACE/$REMOTE_DIR"

NESTED_FIELD="tags.owner"

# The list of Modernisation Platform environments that are to be excluded from the json output
MP_ENVS=("cooker" "example" "sprinkler" "testing")

# Initialize an empty JSON array as a variable
json_output="["

# Track whether this is the first item in the JSON array
first=true

for file in "$DIR"/*.json; do

  if [ -f "$file" ]; then

    # Strips the '.json' suffix from the file name to leave just the environment name.
    FILE_NAME=$(basename "$file" .json)

    # Ensures we ignore the Modernisaiton Platform environments.
    if [[ ! " ${MP_ENVS[@]} " =~ " $file " ]]; then

      file_path="$REMOTE_DIR/$FILE_NAME.json"
  
      echo "$file_path"

      # Using api.github.com to get the first commit of the file.
      creation_date=$(curl -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/commits?path=$file_path&per_page=100" | \
        jq -r '.[-1].commit.committer.date' | cut -d'T' -f1)

      echo "First commit date = $creation_date"

      # Convert $creation_date into a date variable.
      formatted_date=$(date -d "$creation_date" '+%Y-%m-%d') || { echo "Invalid date format for Created Date"; return 1; }

      # Get today's date.
      current_date=$(date '+%Y-%m-%d')
      
      # Convert both dates to seconds since 1970-01-01. This is a reliable way to calculate a diff between two dates.
      current_timestamp=$(date -d "$current_date" '+%s') || { echo "Invalid current date"; exit 1; }
      formatted_timestamp=$(date -d "$formatted_date" '+%s') || { echo "Invalid formatted date"; exit 1; }

      # Get the diff between the current & first commit dates and then convert it into approx months
      diff_in_seconds=$((current_timestamp - formatted_timestamp))
      months_ago=$((diff_in_seconds / 2592000))

      echo "Commit date is $months_ago months old"
      echo "\n"
      echo "\n"
      echo "-------------------------------------"
      echo "\n"

      # This tests that the months_ago value is divisible by the PERIOD. For a 6 month cycle it will ensure it is included just once. 
      if (( months_ago % $PERIOD == 0 )); then
            
        VALUE=$(jq -r ".$NESTED_FIELD" "$file" 2>/dev/null)
          
        if [ -n "$VALUE" ] && [ "$VALUE" != "null" ]; then
          # Count the number of parts when split by colon. We do this as some have multiple values.
          PART_COUNT=$(echo "$VALUE" | awk -F: '{print NF}')
          
          # If there is more than one part, use the second as that is the email address
          if [ "$PART_COUNT" -gt 1 ]; then
            OWNER_PART=$(echo "$VALUE" | awk -F: '{print $2}' | xargs)
          else
            OWNER_PART=$(echo "$VALUE" | awk -F: '{print $1}' | xargs)
          fi
                  
          # If this is not the first item, add a comma separator.
          if [ "$first" = false ]; then
            json_output+=","
          fi
          
          json_output+="
  {
    \"file\": \"$FILE_NAME\",
    \"owner\": \"$OWNER_PART\"
  }"

          first=false

        fi # end of check to exclude MP's own environments.

      fi # end of check whether owner field is in multiple parts.

    fi # end of check whether file was created n months ago.
 
  fi # end of check for .json files in Dir.

done

json_output+="
]"

printf "%s" "$json_output" > output.json 2> /dev/null

# checking whether no environments were found that were created n days ago as we do not want to continue to the next steps.
if [ "$first" = true ]; then
  echo "No files to be processed. Job will stop"
  printf "%s" "true" > stop.json 2> /dev/null
  exit 0
else
  echo "Environments identified as in scope"
fi

echo "Validating JSON Output"

# Validate json.
if ! jq . output.json > /dev/null 2>&1; then
    echo "Error processing json."
    exit 1
else
    echo "Json output is valid"
    cat output.json
fi

