# check final_users.list is exist
if [ -f final_users.list ]; then
  while read username; do
    # Disable console access for the user
    if aws iam get-login-profile --user-name "$username" &> /dev/null; then
      aws iam delete-login-profile --user-name "$username"
      echo "Console access for $username has been disabled"
    fi
    # Get a list of access keys for the user and deactivate them if they are active
    access_keys=$(aws iam list-access-keys --user-name $username --query "AccessKeyMetadata[].AccessKeyId" --output text 2>/dev/null | xargs -n 1)
    if [ ! -z $access_keys ]; then
      while read -r key; do
        aws iam update-access-key --access-key-id $key --status Inactive --user-name $username
      done <<< "$access_keys"
    fi
  done <<< "$(cat final_users.list)"
else
  echo "There are no inactive collaborator users with an inactivity period of 120 days or longer."
fi