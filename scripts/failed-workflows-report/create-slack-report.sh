#!/bin/bash

# Generate a Slack report from the previous step's recent_failures.json.
# If there are no failures, generate a "no failures found" message.

formatted_date="${formatted_date:-}"

echo "$formatted_date"

if [ -f recent_failures.json ] &&
  jq -e 'type == "array" and length > 0' recent_failures.json >/dev/null 2>&1; then

  slack_message=$(jq -n \
    --arg formatted_date "$formatted_date" \
    --arg repository "$GITHUB_REPO" \
    --slurpfile failures recent_failures.json '
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
  slack_message=$(jq -n \
    --arg formatted_date "$formatted_date" \
    --arg repository "$GITHUB_REPO" '
    {
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": ":white_check_mark: *Failed GitHub Actions Report - \($repository)*\nNo failed workflows found since \($formatted_date)."
          }
        }
      ]
    }'
  )
fi

# Save the report for the next step.
printf '%s\n' "$slack_message" > slack_message.json

if jq empty slack_message.json >/dev/null 2>&1; then
  echo "slack_message is valid JSON."
else
  echo "ERROR - slack_message is not valid JSON."
  echo "sendreport=false" >> "$GITHUB_OUTPUT"
  exit 1
fi
