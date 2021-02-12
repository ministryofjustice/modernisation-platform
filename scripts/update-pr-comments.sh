#!/usr/bin/env bash

OUTPUT="{\"body\":\"`echo ${1} | base64 -d | sed 's/ /\\./g'`\"}"

# Remove additional information from GITHUB_REPOSITORY name when using ACT
GITHUB_REPOSITORY=`echo ${GITHUB_REPOSITORY} | sed 's/.*://g'`

# Update github PR with Terraform plan output as a comment
curl -s -f -X POST -d ${OUTPUT} \
-H "Authorization: token ${SECRET}" \
"https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${PULL_REQUEST_NUMBER}/comments"
if [ ${?} -ne 0 ]
then
  echo "ERROR: update-pr-comments.sh exited with an error"
  exit 1
fi