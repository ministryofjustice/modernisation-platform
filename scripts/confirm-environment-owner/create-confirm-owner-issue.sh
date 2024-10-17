#!/bin/bash

# This script generates the github issue and then notifies the owner via a call to a separate python script.

# Validate that the output from the previous step is valid.
if ! jq . output.json; then
    echo "Error processing json."
    exit 1
fi

# Iterate through each environment from the file.
for row in $(jq -c '.[]' "output.json"); do

    # Extract the file and owner values using jq
    file=$(echo "$row" | jq -r '.file')
    owner=$(echo "$row" | jq -r '.owner')

    # For now we only test with sprinkler
    if [ "$file" == "sprinkler" ]; then

        echo "$file"
        echo "$owner"

        # Check if there is an existing open issue to the owner confirmation of the environment     
        open_issue=$(gh issue list -R ministryofjustice/modernisation-platform --search "Confirmation of Onwer Details Required - Environment: $file in:title" --state open)

        # Test whether an issue already exists for the environment in question. If not, then proceed.
        if [ -z "$open_issue" ]; then

            # Creating GitHub Issue to Notify Owner & get the URL link for the issue.
            echo "Creating GitHub Issue to confirm the owner $owner for environment $file"
            issue_url=$(gh issue create \
                --title "Confirmation of Owner Details Required - Environment: $file" \
                --label security \
                --project "Modernisation Platform" \
                --body "Can you please review the contact details provided in the Owner field in environments/$file.json and create a PR if an update is necessary. Consult [this documentation](https://user-guide.modernisation-platform.service.justice.gov.uk/runbooks/reviewing-owners.html#review-owner)" \
            )
            echo "issue_url=$issue_url" >> $GITHUB_ENV
            echo "created_issue=true" >> $GITHUB_ENV    

            if [ "$created_issue" != "true" ] && [ -z "$issue_url" ]; then
                echo "Error - No environment owners have been identified."
            else
                echo "Notify python here"
            fi
        else
            echo "An issue already exists for environment $file"
        fi
    fi
done
