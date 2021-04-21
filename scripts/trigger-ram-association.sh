#!/usr/bin/env bash
REPOSITORY_URL=https://api.github.com/repos/ministryofjustice/modernisation-platform-environments/dispatches
# Pass the environment in and create the payload
PAYLOAD=$(echo "${1}" | jq -R --slurp '{"event_type": "ram-share-assoc-workflow", "client_payload": { "environment":.}}')

# Trigger the ram-association.yml workflow in the modernisation-platform-environments repository
echo "${PAYLOAD}" | curl \
  -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${TERRAFORM_GITHUB_TOKEN}" \
  -d @- $REPOSITORY_URL
ERRORCODE="${?}"
if [ ${ERRORCODE} -ne 0 ]
then
  echo "ERROR: trigger-ram-association.sh exited with an error - Code:${ERRORCODE}"
  exit 1
fi
