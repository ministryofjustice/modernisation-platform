#!/bin/bash

set -e
set -o pipefail

get-diff() {
  diff=`comm <(tr ' ' '\n' <<<"$1" | sort) <(tr ' ' '\n' <<<"$2" | sort)`
  echo "$(tput -T xterm setaf 1)Diff: $diff$(tput -T xterm sgr0)"
}

check-environment-files-present() {
  test_data=`cat policies/environments/expected.rego | sed '1,5d'`
  accounts=`jq -rn --argjson DATA "${test_data}" '$DATA.accounts[]' | sort | tr -s '\n' ' '`
  files=`ls -d environments/*.json | sed 's/environments\///g' | sed 's/.json//g' | sort | tr -s '\n' ' '`
  
  if [[ "$files" == "$accounts" ]]
  then
    echo "$(tput -T xterm setaf 2)PASS - Environment files check$(tput -T xterm sgr0)"
  else
    echo "$(tput -T xterm setaf 1)FAILED - Extra or missing environments/*.json files$(tput -T xterm sgr0)"
    get-diff "$accounts" "$files"
    exit 1
  fi
}

check-network-files-present() {
  test_data=`cat policies/networking/expected.rego | sed '1,5d'`
  business_units=`jq -rn --argjson DATA "${test_data}" '$DATA.subnet_sets | keys | .[]' | sort | tr -s '\n' ' '`
  files=`ls -d environments-networks/*.json | sed 's/environments-networks\///g' | sed 's/.json//g' | sort | tr -s '\n' ' '`

  if [[ "$files" == "$business_units" ]]
  then
    echo "$(tput -T xterm setaf 2)PASS - Environment network files check$(tput -T xterm sgr0)"
  else
    echo "$(tput -T xterm setaf 1)FAILED - Extra of missing environments-network/*.json files$(tput -T xterm sgr0)"
    get-diff "$business_units" "$files"
    exit 1
  fi
}

# Run OPA tests with conftest
environments() {
  jq -n -c -r '[ inputs | . + { filename: input_filename } ]' environments/*.json | conftest test -p policies/environments -
}

networking() {
  jq -n -c -r '[ inputs | . + { filename: input_filename } ]' environments-networks/*.json | conftest test -p policies/networking -
}

member() {
  jq -n -c -r '[ inputs | . + { filename: input_filename } | select( .["account-type"] == "member" ) ]' environments/*.json | conftest test -p policies/member -
}

collaborators(){
    jq -n -c -r '[ inputs | . + { filename: input_filename } ]' collaborators.json | conftest test -p policies/collaborators -
}

main() {
  check-environment-files-present
  check-network-files-present
  environments & environments_outcome=$!
  networking & networking_outcome=$!
  member & member_outcome=$!
  collaborators & collaborators_outcome=$!
  wait $environments_outcome
  wait $networking_outcome
  wait $member_outcome
  wait $collaborators_outcome
}

main
