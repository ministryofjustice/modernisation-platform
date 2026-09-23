#!/bin/bash

# Get IAM users in the specified group and delete access keys that have
# never been used or were last used more than threshold days ago.

group_name="${group_name:-}"
threshold="${threshold:-}"

if [[ -z "$group_name" ]]; then
  echo "Error: group_name is not set." >&2
  exit 1
fi

if [[ ! "$threshold" =~ ^[0-9]+$ ]]; then
  echo "Error: threshold must be a non-negative integer." >&2
  exit 1
fi

cutoff_timestamp=$(date -d "$threshold days ago" +%s) || exit 1

if ! users=$(aws iam get-group \
  --group-name "$group_name" \
  --query 'Users[*].[UserName,PasswordLastUsed]' \
  --output text); then
  echo "Error: Failed to retrieve IAM users from the ${group_name} group. Please check AWS CLI configuration and permissions." >&2
  exit 1
fi

inactive_users=""

while read -r username _; do
  # An empty AWS result must not trigger a lookup for an empty username.
  [[ -n "$username" ]] || continue

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

  for access_key_id in "${access_key_ids[@]}"; do
    if ! last_used=$(aws iam get-access-key-last-used \
      --access-key-id "$access_key_id" \
      --query 'AccessKeyLastUsed.LastUsedDate' \
      --output text); then
      echo "Error: Failed to retrieve last-used date for $access_key_id." >&2
      exit 1
    fi

    if [[ "$last_used" == "None" ]]; then
      should_delete=true
    elif last_used_timestamp=$(date -d "$last_used" +%s); then
      should_delete=false
      if (( last_used_timestamp <= cutoff_timestamp )); then
        should_delete=true
      fi
    else
      echo "Error: Invalid last-used date for $access_key_id: $last_used" >&2
      exit 1
    fi

    if [[ "$should_delete" == true ]]; then
      if ! aws iam delete-access-key \
        --access-key-id "$access_key_id" \
        --user-name "$username"; then
        echo "Error: Failed to delete access key $access_key_id for $username." >&2
        exit 1
      fi
      inactive_users+=" $username"
    fi
  done
done <<< "$users"

unique_inactive_users=$(
  printf '%s\n' "$inactive_users" |
    tr ' ' '\n' |
    sed '/^$/d; s/-superadmin$//' |
    sort -u
)

if [[ -n "$unique_inactive_users" ]]; then
  printf '%s\n' "$unique_inactive_users" > "${group_name}.list"
else
  echo "No inactive users found."
  true > "${group_name}.list"
fi
