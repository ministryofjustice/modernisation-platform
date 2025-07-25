#!/bin/bash

# Check if GITHUB_TOKEN is set

# Ensure GITHUB_TOKEN is set
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "GITHUB_TOKEN is not set. Please export it in your .zshrc."
  exit 1
fi

# Search for repos with 'modernisation-platform' in the name
REPOS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/search/repositories?q=modernisation-platform+in:name&per_page=100" | \
    jq -r '.items[].clone_url')

# Loop and clone each repo
for REPO in $REPOS; do
    echo "Cloning $REPO"
    git clone "$REPO"
done