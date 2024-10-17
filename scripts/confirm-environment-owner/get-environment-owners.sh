#!/bin/bash

# This script outputs a json file containing:
# - The environment name
# - The email address of the "owner" field in "tags".
# Note that it assumes that if multiple fields in "owner" it will take the 2nd field and delimit using ":"

# Directory containing JSON files
DIR="$GITHUB_WORKSPACE/environments"

# The nested field for owner within tags.
NESTED_FIELD="tags.owner"

# Initialize an empty JSON array as a variable
json_output="["

# Track whether this is the first item in the JSON array
first=true

# Loop through each JSON file in the directory
for file in "$DIR"/*.json; do
  if [ -f "$file" ]; then
    # Extract the value of the nested field
    VALUE=$(jq -r ".$NESTED_FIELD" "$file" 2>/dev/null)
    
    # Check if the value was found and is not null
    if [ -n "$VALUE" ] && [ "$VALUE" != "null" ]; then
      # Count the number of parts when split by colon. We do this as some have multiple values.
      PART_COUNT=$(echo "$VALUE" | awk -F: '{print NF}')
      
      # If there is more than one part, use the second as that is the email address
      if [ "$PART_COUNT" -gt 1 ]; then
        OWNER_PART=$(echo "$VALUE" | awk -F: '{print $2}' | xargs)  # Trim any leading/trailing spaces
      else
        OWNER_PART=$(echo "$VALUE" | awk -F: '{print $1}' | xargs)  # Trim any leading/trailing spaces
      fi
      
      # Strip the '.json' suffix from the file name to leave just the environment name.
      FILE_NAME=$(basename "$file" .json)
      
      # If this is not the first item, add a comma separator.
      if [ "$first" = false ]; then
        json_output+=","
      fi
      
      # Add the file name (without .json) and the owner as a JSON object to the variable
      json_output+="
  {
    \"file\": \"$FILE_NAME\",
    \"owner\": \"$OWNER_PART\"
  }"

      # Set first to false after the first valid output as we have iterated past the first.
      first=false
    fi
  fi
done

# Close the JSON array
json_output+="
]"

# Assign the final JSON string to a file to be used across other steps in the job.
printf "%s" "$json_output" > output.json 2> /dev/null

# Validate the json.
if ! jq . output.json > /dev/null 2>&1; then
    echo "Error processing json."
    exit 1
else
    echo "Json output is valid"
fi

