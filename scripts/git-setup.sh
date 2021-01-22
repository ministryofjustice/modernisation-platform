#!/bin/bash

name=$(git config --get user.name)
email=$(git config --get user.email)

if [ -z "$name" ]; then
  git config --global user.name "modernisation-platform-ci"
fi

if [ -z "$email" ]; then
  git config --global user.email "modernisation-platform+github@digital.justice.gov.uk"
fi
