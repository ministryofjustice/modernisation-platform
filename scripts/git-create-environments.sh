#!/bin/bash

set -e
set -x

github_org="ministryofjustice"
repository="${github_org}/modernisation-platform-environments"
secret=$TERRAFORM_GITHUB_TOKEN

get_existing_environments() {
  page=1
  github_environments=""

  while :; do
    response=$(curl -s \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${secret}" \
      "https://api.github.com/repos/${repository}/environments?per_page=100&page=${page}")

    current_page_environments=$(echo $response | jq -r '.environments[].name')
    github_environments="${github_environments} ${current_page_environments}"

    # Check if there's a "next" link in the headers
    next_link=$(echo "$response" | grep -i '^link:' | sed -n 's/.*<\(.*\)>; rel="next".*/\1/p')

    if [ -z "$next_link" ]; then
      break  # No more pages to fetch
    else
      page=$((page + 1))
    fi
  done

  echo "Existing github environments: $github_environments"
}

get_github_team_id() {
  team_slug=${1}
  echo "Getting team id for team: ${team_slug}"
  response=$(curl -s \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${secret}" \
    https://api.github.com/orgs/${github_org}/teams/${team_slug})
  team_id=$(echo ${response} | jq -r '.id')
  # echo "Team ID for ${team_slug}: ${team_id}"
  team_ids="${team_ids} ${team_id}"
}

check_if_environment_exists() {
  echo "Checking if environment $1 exists..."
  [[ $github_environments =~ (^|[[:space:]])$1($|[[:space:]]) ]] && environment_exists="true" || environment_exists="false"
  echo "Environment $1 exists = ${environment_exists}"
}

check_if_change_to_application_json() {
  echo "Checking if application $1 has changes..."
  changed_envs=$(git diff --no-commit-id --name-only -r @^ | awk '{print $1}' | grep ".json" | grep -a "environments//*"  | uniq | cut -f2-4 -d"/" | sed 's/.\{5\}$//')
  echo "Changed json files=$changed_envs"
  application_name=$(echo $1 | sed 's/-[^-]*$//')
  echo "Application name: $application_name"
  [[ $changed_envs =~ (^|[[:space:]])$application_name($|[[:space:]]) ]] && change_to_application_json="true" || change_to_application_json="false"
  echo "Change to application json: $change_to_application_json"
}

create_environment() {
  environment_name=$1
  github_teams=$2
  echo "Creating environment ${environment_name}..."
  # echo "Teams for payload: ${github_teams}"
  if [ "${env}" == "preproduction" ] || [ "${env}" == "production" ]
  then
    payload="{\"deployment_branch_policy\":{\"protected_branches\":true,\"custom_branch_policies\":false},\"reviewers\": [${github_teams}]}"
  else
    payload="{\"reviewers\": [${github_teams}]}"
  fi
  echo "Payload: $payload"
  echo "Repository: ${repository}"
  echo "${payload}" | curl -L -s \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${secret}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${repository}/environments/${environment_name}\
  -d @- > /dev/null 2>&1
}

create_reviewers_json() {
  ids=$1
  for id in ${ids}
  do
    # echo "Adding Team ID: $id"
    raw_jq=`jq -cn --arg team_id "$id" '{ "type": "Team", "id": $team_id|tonumber }'`
    reviewers_json="${raw_jq},${reviewers_json}"
    # echo "Reviewers json in loop: ${reviewers_json}"
  done
  # remove trailing commas
  reviewers_json=`echo ${reviewers_json} | sed 's/,*$//g'`
  # echo "Reviewers json: ${reviewers_json}"
}

add_additional_reviewers() {
  environment_name=$1
  additional_reviewers=$2
  echo "Adding additional reviewers to ${environment_name}..."
  
  # Construct reviewers JSON for additional reviewers
  additional_reviewers_json="["
  for reviewer in ${additional_reviewers}
  do
    raw_jq=`jq -cn --arg reviewer "$reviewer" '{ "type": "User", "login": $reviewer }'`
    additional_reviewers_json="${additional_reviewers_json}${raw_jq},"
  done
  additional_reviewers_json="${additional_reviewers_json%,}"  # Remove trailing comma
  additional_reviewers_json="${additional_reviewers_json}]"

  # Update the environment on GitHub with additional reviewers
  echo "{\"reviewers\": [${additional_reviewers_json}]}" | curl -L -s \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${secret}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/${repository}/environments/${environment_name}\
    -d @- > /dev/null 2>&1
}

main() {
  #load existing github environments
  get_existing_environments
  # Loop through each application json file
  for json_file in ./environments/*.json
  do
    echo
    echo "***************************************"
    echo "Processing file: ${json_file}"  
    application=`basename "${json_file}" .json`

    # Loop through each environment
    for env in `cat "${json_file}" | jq -r --arg FILENAME "${application}" '.environments[].name'`
    do
      echo
      environment="${application}-${env}"
      echo "Processing environment: ${environment}"
      # Check it's a member environment
      account_type=$(jq -r '."account-type"' ${json_file})
      if [ "${account_type}" = "member" ]
      then
        # Get environment github team slugs
        teams=$(jq -r --arg e "${env}" '.environments[] | select( .name == $e ) | .access[].github_slug' $json_file)
        echo "Teams for $environment: $teams"
        # Check if environment exists and that if has a team associated with it
        environment_exists="false"
        check_if_environment_exists "${environment}"
        change_to_application_json="false"
        check_if_change_to_application_json "${environment}"
        
        if ([ "${environment_exists}" == "true" ] || [ "${teams}" == "" ]) && [ "${change_to_application_json}" == "false" ]
        then
          echo "${environment} already exists and there are no changes, or no GitHub team has been assigned, skipping..."
        else
          echo "Creating environment ${environment}"
          # Get github team ids
          team_ids=""
          for team in ${teams}
          do
            get_github_team_id ${team}
          done
          # echo "Team IDs for ${environment}: ${team_ids}"
          # Create reviewers json
          reviewers_json=""
          create_reviewers_json "${team_ids}"
          create_environment ${environment} ${reviewers_json}
          
          # Use jq to conditionally extract additional reviewers
          additional_reviewers=$(jq -r --arg e "${env}" '.environments[] | select( .name == $e and has("additional_reviewers")) | .additional_reviewers[]' $json_file)
          
          if [ -n "$additional_reviewers" ]
          then
            echo "Additional reviewers for ${environment}: $additional_reviewers"
            add_additional_reviewers "${environment}" "${additional_reviewers}"
          else
            echo "No additional reviewers specified for ${environment}."
          fi
        fi
      else
        echo "${environment} is a core environment, skipping..."
      fi
    done
  done
}

main
