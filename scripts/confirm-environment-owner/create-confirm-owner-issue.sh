#!/bin/bash

# This script generates the github issue and then notifies the owner via a call to a separate python script.

# Validate that the output from the previous step of the job.
if ! jq . output.json > /dev/null 2>&1; then
    echo "Error processing json."
    exit 1
else
    echo "Valid JSON input"
fi

# Iterate through each environment from the file. We use this method because some owners have spaces in the text.
jq -c '.[]' "output.json" | while IFS= read -r row; do

    file=$(echo "$row" | jq -r '.file')
    owner=$(echo "$row" | jq -r '.owner')

    # For now we only test with sprinkler
    if [ "$file" == "sprinkler" ]; then

        echo "Processing Sprinkler"

        # Check if there is an existing open issue for the environment as we don't want duplicates.
        open_issue=$(gh issue list -R ministryofjustice/modernisation-platform --search "Confirmation of Onwer Details Required - Environment: $file in:title" --state open)

        if [ -z "$open_issue" ]; then

            # Creating GitHub Issue.
            echo "Creating GitHub Issue to confirm the owner $owner for environment $file"
            issue_url=$(gh issue create \
                -t "Confirmation of Owner Details Required - Environment: $file" \
                -l "security" \
                -b "Can you please review the contact details provided in the Owner field in environments/$file.json and create a PR if an update is necessary. Consult [this documentation](https://user-guide.modernisation-platform.service.justice.gov.uk/runbooks/reviewing-owners.html#review-owner)" \
            )
  
            if [ -z "$issue_url" ]; then
                echo "Error - Github issue not created."
                exit 1
            else
                echo "Notifying the Owner via email using Gov Notify"
                echo "$file"
                echo "$owner"
                echo "$issue_url"
                python ./scripts/confirm-environment-owner/owner-notification.py "$file" "$owner" "$issue_url"
            fi
        else
            echo "An open issue already exists for environment $file. See $open_issue"
        fi
    fi
done
