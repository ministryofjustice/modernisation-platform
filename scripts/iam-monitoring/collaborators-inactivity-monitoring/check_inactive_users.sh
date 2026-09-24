#!/bin/bash

# Get IAM users in the "collaborators" group along with their last console login activity.

threshold="${threshold:-}"

if [[ ! "$threshold" =~ ^[0-9]+$ ]]; then
  echo "Error: threshold must be a non-negative integer." >&2
  exit 1
fi

cutoff_timestamp=$(date -d "$threshold days ago" +%s) || exit 1

if ! users=$(aws iam get-group \
  --group-name collaborators \
  --query 'Users[*].[UserName,PasswordLastUsed]' \
  --output text); then
  echo "Error: Failed to retrieve IAM users from the 'collaborators' group. Please check AWS CLI configuration and permissions." >&2
  exit 1
fi

final_users=""

while read -r username lastactivity; do
  [[ -n "$username" ]] || continue

  # When requested, skip users without a console login profile.
  if [[ -n "${SKIP_DISABLED_CONSOLE_USERS:-}" ]]; then
    login_profile=$(aws iam get-login-profile --user-name "$username" 2>/dev/null)
    if [[ -z "$login_profile" ]]; then
      continue
    fi
  fi

  if [[ "$lastactivity" == "None" ]]; then
    if ! creation_date=$(aws iam get-user \
      --user-name "$username" \
      --query 'User.CreateDate' \
      --output text); then
      echo "Error: Failed to retrieve creation date for $username." >&2
      exit 1
    fi

    if ! creation_timestamp=$(date -d "$creation_date" +%s); then
      echo "Error: Invalid creation date for $username: $creation_date" >&2
      exit 1
    fi

    if (( creation_timestamp <= cutoff_timestamp )); then
      final_users+=" $username"
    fi
  else
    if ! lastactivity_timestamp=$(date -d "$lastactivity" +%s); then
      echo "Error: Invalid last console login date for $username: $lastactivity" >&2
      exit 1
    fi

    if (( lastactivity_timestamp <= cutoff_timestamp )); then
      if ! access_keys=$(aws iam list-access-keys \
        --user-name "$username" \
        --query 'AccessKeyMetadata[].AccessKeyId' \
        --output text); then
        echo "Error: Failed to retrieve access keys for $username." >&2
        exit 1
      fi

      meets_criteria=true

      if [[ -n "$access_keys" && "$access_keys" != "None" ]]; then
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

          if [[ "$last_used" != "None" ]]; then
            if ! last_used_timestamp=$(date -d "$last_used" +%s); then
              echo "Error: Invalid last-used date for $access_key_id: $last_used" >&2
              exit 1
            fi

            if (( last_used_timestamp >= cutoff_timestamp )); then
              meets_criteria=false
              break
            fi
          fi
        done
      fi

      if [[ "$meets_criteria" == true ]]; then
        final_users+=" $username"
      fi
    fi
  fi
done <<< "$users"

# Always replace the output file so an earlier run cannot leave stale users.
if [[ -n "$final_users" ]]; then
  printf '%s\n' "$final_users" | xargs -n 1 > final_users.list
else
  true > final_users.list
fi
