#!/bin/bash

if [ ! -z "$2" ]; then
  GIT_DIR=$2
  cd $GIT_DIR
  GITHUB_REPOSITORY=$(basename `git rev-parse --show-toplevel`)
  GITHUB_REPOSITORY="ministryofjustice/$GITHUB_REPOSITORY"
  TOKEN=$TERRAFORM_GITHUB_TOKEN
else
  TOKEN=$GITHUB_TOKEN
fi

branch="date-$(date +%s)"
commit_message="Workflow: created files in ${1}"

git checkout -b "$branch"
git add "$1"
git commit -m "$commit_message"
git remote rm origin || true
git remote add origin "https://${TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git push -u origin "$branch"

git status
