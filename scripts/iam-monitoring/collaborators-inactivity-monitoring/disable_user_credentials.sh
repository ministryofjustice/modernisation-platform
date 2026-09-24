#!/bin/bash

if [[ ! -f final_users.list ]]; then
  echo "There are no inactive collaborator users with an inactivity period of 120 days or longer."
  exit 0
fi

while IFS= read -r username || [[ -n "$username" ]]; do
  [[ -n "$username" ]] || continue

  # Disable console access if the user has a login profile.
  if aws iam get-login-profile --user-name "$username" &>/dev/null; then
    if ! aws iam delete-login-profile --user-name "$username"; then
      echo "Error: Failed to disable console access for $username." >&2
      exit 1
    fi
    echo "Console access for $username has been disabled"
  fi

  # Get the user's access keys.
  if ! access_keys=$(aws iam list-access-keys \
    --user-name "$username" \
    --query 'AccessKeyMetadata[].AccessKeyId' \
    --output text); then
    echo "Error: Failed to retrieve access keys for $username." >&2
    exit 1
  fi

  [[ -n "$access_keys" && "$access_keys" != "None" ]] || continue

  # AWS CLI text output separates access key IDs with whitespace.
  read -r -a access_key_ids <<< "$access_keys"

  for key in "${access_key_ids[@]}"; do
    if ! aws iam update-access-key \
      --access-key-id "$key" \
      --status Inactive \
      --user-name "$username"; then
      echo "Error: Failed to deactivate access key $key for $username." >&2
      exit 1
    fi
  done
done < final_users.list
