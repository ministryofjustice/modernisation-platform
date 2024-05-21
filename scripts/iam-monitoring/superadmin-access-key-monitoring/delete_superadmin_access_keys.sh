#!/bin/bash
# Get IAM users in the "superadmins" group along with their last console login activity
superadmin_users=$(aws iam get-group --group-name superadmins --query 'Users[*].[UserName,PasswordLastUsed]' --output text)
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve IAM users from the 'superadmins' group. Please check AWS CLI configuration and permissions." >&2
  exit 1
fi

# Initialize an empty list to store the users whose access keys will be deleted
inactive_users=""

# Loop through each user in the "superadmins" group
while read -r username lastactivity; do
    # Get information about the access keys for the current user
    access_keys=$(aws iam list-access-keys --user-name "$username" --query 'AccessKeyMetadata[].AccessKeyId' --output text)
    if [[ ! -z $access_keys ]]; then 
       for access_key_id in $access_keys; do
        # Get the last used date of the access key
        last_used=$(aws iam get-access-key-last-used --access-key-id "$access_key_id" --query 'AccessKeyLastUsed.LastUsedDate' --output text)
        # Check if the access key was never used or has not been used within the threshold
        if [ "$last_used" == "None" ] || [ "$(gdate -d "$last_used" +%s)" -le "$(gdate -d "now - $threshold days" +%s)" ]; then
          # Delete the inactive access key
          aws iam delete-access-key --access-key-id $access_key_id --user-name $username
          inactive_users+=" $username"
        fi
       done
    fi
done <<< "$superadmin_users"

# Remove duplicates from the list of inactive users and strip any suffixes
unique_inactive_users=$(echo "$inactive_users" | tr ' ' '\n' | sed 's/-superadmin$//' | sort -u)

# Save the list of unique inactive users to a file
echo $unique_inactive_users | xargs -n 1 > unique_inactive_users.list