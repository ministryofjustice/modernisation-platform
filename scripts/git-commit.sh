#!/bin/bash

branch="date-$(date +%s)"
commit_message="Workflow: created files in ${1}"

git checkout -b "$branch"
git add "$1"
git commit -m "$commit_message"
git remote rm origin || true
git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git push -u origin "$branch"

git status
