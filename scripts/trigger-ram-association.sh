#!/usr/bin/env bash
REPOSITORY_URL=https://api.github.com/repos/ministyofjustice/modernisation-platform-environments/actions/workflows/ram-association.yaml/dispatches
PAYLOAD=$(echo "${1}" | jq -R --slurp '{"client_payload": { "environment":.}')


# Update github PR with Terraform plan output as a comment
echo "${PAYLOAD}" | curl \
  -s -X POST \
  -H "Accept: application/vnd.github.everest-preview+json" \
  -H "Authorization: token ${TERRAFORM_GITHUB_TOKEN}" \
  -d @- $REPOSITORY_URL > /dev/null
ERRORCODE="${?}"
if [ ${ERRORCODE} -ne 0 ]
then
  echo "ERROR: update-pr-comments.sh exited with an error - Code:${ERRORCODE}"
  exit 1
fi