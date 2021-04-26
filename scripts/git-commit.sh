#!/bin/bash

if [ ! -z "$2" ]; then
  GIT_DIR=$2
  echo "GIR_DIR in if statement: $GIT_DIR"
  cd $GIT_DIR
  echo "Before: $GITHUB_REPOSITORY"
  GITHUB_REPOSITORY=$(basename `git rev-parse --show-toplevel`)
  GITHUB_REPOSITORY="ministryofjustice/$GITHUB_REPOSITORY"
  echo "After: $GITHUB_REPOSITORY"
  TOKEN="modernisation-platform-ci:$TERRAFORM_GITHUB_TOKEN"
  echo "token after:"
  echo $TOKEN | sed 's/.*\(...\)/\1/'
else
  TOKEN=$GITHUB_TOKEN
fi

branch="date-$(date +%s)"
commit_message="Workflow: created files in ${1}"

git checkout -b "$branch"
git add "$1"
git commit -m "$commit_message"
echo "Commit Message finished"
git remote rm origin || true
echo "git remote remove finished"
git remote -v add origin "https://${TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
echo "git remote add finished"
git remote -v
git push --verbose -u origin "$branch"

git status
