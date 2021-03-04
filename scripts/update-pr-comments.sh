#!/usr/bin/env bash

# Remove additional information from GITHUB_REPOSITORY name when using ACT
GITHUB_REPOSITORY=`echo ${GITHUB_REPOSITORY} | sed 's/.*://g'`

REPOSITORY_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${PULL_REQUEST_NUMBER}/comments"
PAYLOAD=$(echo "${1}" | jq -R --slurp '{body:.}')

# Update github PR with Terraform plan output as a comment
echo "${PAYLOAD}" | curl \
  -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${SECRET}" \
  -d @- $REPOSITORY_URL > /dev/null
ERRORCODE="${?}"
if [ ${ERRORCODE} -ne 0 ]
then
  echo "ERROR: update-pr-comments.sh exited with an error - Code:${ERRORCODE}"
  exit 1
fi
