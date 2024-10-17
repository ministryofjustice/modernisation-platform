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

# This variable determines the number of months we look back for created dates.
PERIOD="6"

# Initialize an empty JSON array as a variable
json_output="["

# Track whether this is the first item in the JSON array
first=true

for file in "$DIR"/*.json; do

  if [ -f "$file" ]; then

    # Strips the '.json' suffix from the file name to leave just the environment name.
    FILE_NAME=$(basename "$file" .json)

    file_path="$REMOTE_DIR/$FILE_NAME.json"
 
    echo "$file_path"

    # Using a call to the remote repo as a local checkout will only get the current date.
    #    creation_date=$(gh api /repos/$REPO/commits/main \
    #      -F path="$file_path" \
    #      -q '.[0].commit.committer.date' --header "authorization: token $GH_TOKEN" | cut -d'T' -f1)


    # Using api.github.com to get the first commit of the file.
    creation_date=$(curl -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$REPO/commits?path=$file_path&per_page=100" | \
      jq -r '.[-1].commit.committer.date' | cut -d'T' -f1)

    echo "First commit date = $creation_date"

    # Convert $creation_date into a date variable.
    formatted_date=$(date -d "$creation_date" '+%Y-%m-%d') || { echo "Invalid date format for Created Date"; return 1; }
    echo "Formatted Created Date = $formatted_date"

    # Get today's date.
    current_date=$(date '+%Y-%m-%d')
    echo "Current Date = $current_date"

    # Get the date `months_ago` months ago in "M" format as a dif between the today's date and the created date.
    
    # Convert both dates to seconds since 1970-01-01
    current_timestamp=$(date -d "$current_date" '+%s') || { echo "Invalid current date"; exit 1; }
    echo "current_timestamp = $current_timestamp"
    formatted_timestamp=$(date -d "$formatted_date" '+%s') || { echo "Invalid formatted date"; exit 1; }
    echo "formatted_timestamp = $formatted_timestamp"

    diff_in_seconds=$((current_timestamp - formatted_timestamp))
    months_ago=$((diff_in_seconds / 2592000))

    echo "Commit date is $months_ago months old"

    if (( months_ago % 6 == 0 )); then

      # No need to check whether the date is the first as we will run the job on that date.
          
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
fi

# Validate json.
if ! jq . output.json > /dev/null 2>&1; then
    echo "Error processing json."
    exit 1
else
    echo "Json output is valid"
    cat output.json
fi

