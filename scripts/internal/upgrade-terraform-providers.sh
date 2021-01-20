#!/bin/bash

current_directory=$(pwd)

upgrade() {
  echo "Starting terraform provider upgrade from $current_directory"
  for directory in $(find . -type d \( -name .terraform -o -name templates -o -name modules \) -prune -o -name '*.tf' -exec dirname {} \; | sort -u)
    do
      echo "" # add spacing around the messages
      echo "$(tput setaf 4)Upgrading terraform providers in $directory$(tput sgr0)"
      terraform -chdir="$directory" init -upgrade
      echo "" # add spacing around the messages
      echo "$(tput setaf 4)Finished upgrading terraform providers in $directory$(tput sgr0)"
      echo "" # add spacing around the messages
  done
}

commit_reminder() {
  echo "" # add spacing around the messages
  echo "$(tput setaf 2)Please commit any updated files!$(tput sgr0)"
}

upgrade && commit_reminder
