#!/bin/bash

echo "Dollar 1: $1"

if [ ! -z "$1" ]; then
  GIT_DIR=$1
  echo "GIR_DIR in if statement: $GIT_DIR"
fi

echo "GIR_DIR: $GIT_DIR"

name=$(git config --get user.name)
email=$(git config --get user.email)

if [ -z "$name" ]; then
  git config --global user.name "modernisation-platform-ci"
fi

if [ -z "$email" ]; then
  git config --global user.email "modernisation-platform+github@digital.justice.gov.uk"
fi

echo "end of file"