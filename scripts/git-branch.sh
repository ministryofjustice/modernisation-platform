#!/bin/sh

# Prefer GitHub Actions env vars if present
if [ -n "$GITHUB_HEAD_REF" ]; then
  # For pull requests, this is the source branch
  echo "{\"branch\": \"$GITHUB_HEAD_REF\"}"
elif [ -n "$GITHUB_REF_NAME" ]; then
  # For push events, this is the branch or tag name
  echo "{\"branch\": \"$GITHUB_REF_NAME\"}"
else
  # Fallback to git (works locally)
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  echo "{\"branch\": \"$branch\"}"
fi