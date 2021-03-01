#!/bin/bash

set -e

environments() {
  jq -n -c -r '[ inputs | . + { filename: input_filename } ]' environments/*.json | conftest test -p policies/environments -
}

networking() {
  jq -n -c -r '[ inputs | . + { filename: input_filename } ]' environments-networks/*.json | conftest test -p policies/networking -
}

main() {
  environments & environments_outcome=$!
  networking & networking_outcome=$!
  wait $environments_outcome
  wait $networking_outcome
}

main
