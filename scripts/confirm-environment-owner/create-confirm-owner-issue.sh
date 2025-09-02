#!/bin/bash

# This script generates the github issue and then notifies the owner via a call to a separate python script.

# The repository
REPO=$GITHUB_REPO

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

    # Github issue title
    GITHUB_ISSUE_TITLE="Confirmation of Owner Details Required - Environment: $file"

    # Check if there is an existing open issue for the environment as we don't want duplicates.
    open_issue=$(gh issue list -R ministryofjustice/modernisation-platform --search " $GITHUB_ISSUE_TITLE in:title" --state open)

    if [ -z "$open_issue" ]; then

        # Creating GitHub Issue.
        echo "Creating GitHub Issue to confirm the owner $owner for environment $file"
        issue_url=$(gh issue create \
            -t "$GITHUB_ISSUE_TITLE" \
            -l "security, kanban" \
            -b "Can you please review the contact details provided in the owner tag in [environments/$file.json](https://github.com/$REPO/blob/main/environments/$file.json) and confirm they are correct. At present the email address we have is $owner. If it needs to be changed you can either:

- Check whether or not any other email addresses are listed in the .json file and include those.
 
- Contact the team via the [#ask-modernisation-team](https://moj.enterprise.slack.com/archives/C01A7QK5VM1) slack channel, or

- Add a comment to this issue and we will update the email address details, or

- Create a pull request with the change and contact us on the #ask-modernisation-team slack channel to review it.

For further information please read this [documentation](https://technical-guidance.service.justice.gov.uk/documentation/standards/documenting-infrastructure-owners.html#tags-you-should-use)."
)

        # Now we send a notification email via Gov.UK Notify. (https://www.notifications.service.gov.uk/)
        if [ -z "$issue_url" ]; then
            echo "Error - Github issue not created."
            exit 1
        else
            echo "Notifying the Owner via email using Gov Notify"
            python ./scripts/confirm-environment-owner/owner-notification.py "$file" "$issue_url" "$owner"
        fi
    else
        echo "An open issue already exists for environment $file. See $open_issue"
    fi

done
