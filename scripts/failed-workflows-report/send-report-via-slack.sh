# This bash script sends the contents of the slack_message.son file to the modernisation platform slack channel.
# It is dependent on the successful creation of the slack_message.json file. Otherwise no report is sent.

#!/bin/bash

# Ensure the script is called with the webhook URL and json file. Otherwise exit.
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 SLACK_WEBHOOK_URL PAYLOAD_FILE"
  exit 1
fi

# Variables for the two inputs. 
SLACK_WEBHOOK_URL="$1"
PAYLOAD_FILE="$2"

# Validate the json file. If it fails then exit.
if ! jq empty "$PAYLOAD_FILE" > /dev/null 2>&1; then
  echo "Error: $PAYLOAD_FILE is not valid JSON or does not exist."
  exit 1
fi

# Reads the payload and adds it to a variable. Then sends to slack the variable as the message data.
PAYLOAD=$(cat "$PAYLOAD_FILE")
response=$(curl -s -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$SLACK_WEBHOOK_URL")

# Check for a successful response
if [[ "$response" == "ok" ]]; then
  echo "Message sent to Slack successfully."
else
  echo "Failed to send message to Slack. Response: $response"
  exit 1
fi
