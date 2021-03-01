#!/bin/bash

# Define: repository URL, branch, title, and PR body
repository_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls"
pull_request_branch=$(git branch --show-current)
pull_request_title="New files for $1"
pull_request_body="> This PR was automatically created via a GitHub action workflow 🤖

This PR commits new files under $1."

payload=$(echo "${pull_request_body}" | jq --arg branch "$pull_request_branch" --arg pr_title "$pull_request_title" -R --slurp '{ body: ., base: "main", head: $branch, title: $pr_title }')

echo "${payload}" | curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  $repository_url \
  -d @- > /dev/null
