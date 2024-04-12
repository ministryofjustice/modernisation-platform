#!/bin/bash

if [ -f final_users.list ]; then
    while read username; do
        # Check if there is an existing open issue to the deletion of the user
        open_issue=$(gh issue list -R ministryofjustice/modernisation-platform --search "Inactive IAM Collaborator Deletion Required - Username: $username in:title" --state open)

        # Creating GitHub Issue to delete collaborator user
        if [ -z "$open_issue" ]; then
            echo "Creating GitHub Issue to delete collaborator user $username"
            gh issue create \
            --title "Inactive IAM Collaborator Deletion Required - Username: $username" \
            --label security \
            --project "Modernisation Platform" \
            --body "The [Collaborator-Inactivity-Monitoring workflow](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}) has detected that the username $username is inactive for more than 180 days.

            Consult [this documentation](https://user-guide.modernisation-platform.service.justice.gov.uk/runbooks/adding-collaborators.html#removing-collaborators) which describes the process for deleting the collaborator user."
        fi
    done <<< "$(cat final_users.list)"
else
    echo "There are no inactive collaborator users with an inactivity period of 180 days or longer."
fi