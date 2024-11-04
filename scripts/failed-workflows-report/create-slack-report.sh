# This takes the output of the previous step and generates a json file containing a markdown-formatted list ready to be sent to slack
# If no file is found from the previous output, it will exit.

# Check if recent_failures.json exists, is not empty, and contains valid JSON. Else exit.
if jq empty recent_failures.json > /dev/null 2>&1; then
    # This generates the slack report of failed workflows as json.
    slack_message=$(jq -n --arg formatted_date "$formatted_date" --arg repository "$GITHUB_REPO" --slurpfile failures recent_failures.json '
    {
        "blocks": (
        [
            {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":no_entry: *Attention - Failed GitHub Actions Report - \($repository)*"
            }
            },
            {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "The following workflows have failed since \($formatted_date) and require attention:"
            }
            },
            {
            "type": "divider"
            }
        ] + ($failures[0] | map(
            {
            "type": "section",
            "fields": [
                {
                "type": "mrkdwn",
                "text": "*Workflow:*\n<\(.url)|\(.name)>"
                },
                {
                "type": "mrkdwn",
                "text": "*Created At:*\n\(.created_at)"
                }
            ]
            },
            {
            "type": "divider"
            }
        ))
        )
    }'
    )
else
    slack_message=$(jq -n --arg formatted_date "$formatted_date" --arg repository "$GITHUB_REPO" '
    {
    "blocks": [
        {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": ":no_entry: *Failed GitHub Actions Report in \($repository)*"
        }
        },
        {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": "No failed workflows were found since \($formatted_date)."
        }
        }
    ]
    }'
    )
fi


# Prints the slack report to the log and outputs to a json file for use in the next step.
echo "$slack_message" > slack_message.json

if jq empty slack_message.json > /dev/null 2>&1; then
  echo "slack_message is valid JSON."
else
  echo "ERROR - slack_message is not valid JSON."
fi