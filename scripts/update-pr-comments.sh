#!/usr/bin/env bash

OUTPUT="{\"body\":\"`echo ${1} | sed 's/ /\\./g'`\"}"

# Update github PR with Terraform plan output as a comment
curl -f -s -X POST -d ${OUTPUT} -H \
"Authorization: token ${SECRET}" \
"https://api.github.com/repos/${GITHUB_REPOSITORY}/issues/${PULL_REQUEST_NUMBER}/comments"
if [ ${?} -ne 0 ]
then
  echo "ERROR: update-pr-comments.sh exited with an error"
  exit 1
fi