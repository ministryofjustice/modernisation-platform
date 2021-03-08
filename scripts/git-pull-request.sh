#!/bin/bash

# Define: repository URL, branch, title, and PR body
repository_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls"
pull_request_branch=$(git branch --show-current)
pull_request_title="New files for $1"
pull_request_body="> This PR was automatically created via a GitHub action workflow 🤖

This PR commits new files under $1."

payload=$(echo "${pull_request_body}" | jq --arg branch "$pull_request_branch" --arg pr_title "$pull_request_title" -R --slurp '{ body: ., base: "main", head: $branch, title: $pr_title }')

echo "${payload}" | curl \
  -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${SECRET}" \
  -d @- $repository_url > /dev/null
ERRORCODE="${?}"
if [ ${ERRORCODE} -ne 0 ]
then
  echo "ERROR: git_pull-request.sh exited with an error - Code:${ERRORCODE}"
  exit 1
fi