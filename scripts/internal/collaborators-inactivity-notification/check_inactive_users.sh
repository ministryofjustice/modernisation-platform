#!/bin/bash

# Get IAM users in the "collaborators" group along with their last console login activity
users=$(aws iam get-group --group-name collaborators --query 'Users[*].[UserName,PasswordLastUsed]' --output text)
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve IAM users from the 'collaborators' group. Please check AWS CLI configuration and permissions." >&2
  exit 1
fi

# Initialize an empty list to store the final users
final_users=""

# Loop through each user in the "collaborators" group
while read -r username lastactivity; do
  # Check if last console login activity is more than or equal to 90 days or is "None"
  if [ "$lastactivity" == "None" ] || [ "$(date -d "$lastactivity" +%s)" -le "$(date -d "now - 90 days" +%s)" ]; then
    # Get information about the access keys for the current user
    access_keys=$(aws iam list-access-keys --user-name "$username" --query 'AccessKeyMetadata[].AccessKeyId' --output text)
    
    # Initialize a flag to track if the user meets the criteria
    meets_criteria=1
    
    # Loop through each access key for the current user
    for access_key_id in $access_keys; do
      # Get the last used information for the access key
      last_used=$(aws iam get-access-key-last-used --access-key-id "$access_key_id" --query 'AccessKeyLastUsed.LastUsedDate' --output text)
      if [ "$last_used" != "None" ] && [ "$(date -d "$last_used" +%s)" -ge "$(date -d "now - 90 days" +%s)" ]; then
        # If any access key was used within the last 90 days, user does not meet the criteria
        meets_criteria=0
        break
      fi
    done
    
    # If user meets the criteria, add them to the final list
    if [ "$meets_criteria" -eq 1 ]; then
      final_users+=" $username"
    fi
  fi
done <<< "$users"

# Output the final list of users
echo "$final_users" | tr ' ' '\n' > final_users.list