#!/bin/bash
COLLAB_FILE="./collaborators.json"
PR_BODY="The following collaborators were inactive for more than $threshold days and have been removed automatically:\n\n"

# Exit if no inactive users
if [ ! -f final_users.list ] || [ ! -s final_users.list ]; then
    echo "No inactive collaborators found. Exiting."
    exit 0
fi

# Read inactive users into array
inactive_users=()
while IFS= read -r user; do
    inactive_users+=("$user")
done < final_users.list

# Remove inactive users
for user in "${inactive_users[@]}"; do
    echo "Removing user $user from $COLLAB_FILE"
    jq --arg username "$user" 'del(.users[] | select(.username == $username))' "$COLLAB_FILE" > "${COLLAB_FILE}.tmp" && mv "${COLLAB_FILE}.tmp" "$COLLAB_FILE"
    PR_BODY+="- $user\n"
done
echo -e "$PR_BODY" > pr_body.txt
echo "Inactive collaborators removed successfully."