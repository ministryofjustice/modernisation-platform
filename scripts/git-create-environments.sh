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
  additional_reviewers=$3  # New parameter for the optional reviewer
  echo "Creating environment ${environment_name}..."
  
  # Modify the payload based on the presence of an additional reviewer
  if [ "${env}" == "preproduction" ] || [ "${env}" == "production" ]; then
    if [ -n "${additional_reviewers}" ]; then
      payload="{\"deployment_branch_policy\":{\"protected_branches\":true,\"custom_branch_policies\":false},\"reviewers\": [${github_teams},${additional_reviewers}]}"
    else
      payload="{\"deployment_branch_policy\":{\"protected_branches\":true,\"custom_branch_policies\":false},\"reviewers\": [${github_teams}]}"
    fi
  else
    if [ -n "${additional_reviewers}" ]; then
      payload="{\"reviewers\": [${github_teams},${additional_reviewers}]}"
    else
      payload="{\"reviewers\": [${github_teams}]}"
    fi
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
  team_slugs=("$@")
  reviewers=()

  for slug in "${team_slugs[@]}"; do
    reviewers+=("{\"type\": \"Team\", \"id\": ${slug}}")
  done

  if [ -n "${additional_reviewers}" ]; then
    IFS=',' read -ra user_logins <<< "${additional_reviewers}"
    for login in "${user_logins[@]}"; do
      reviewers+=("{\"type\": \"User\", \"login\": \"$login\"}")
    done
  fi

  reviewers_json=$(IFS=','; echo "[${reviewers[*]}]")
  echo "Reviewers json: ${reviewers_json}"
}

main() {
  # Load existing GitHub environments
  get_existing_environments
  # Loop through each application JSON file
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
      # Check if it's a member environment
      account_type=$(jq -r '."account-type"' ${json_file})
      if [ "${account_type}" = "member" ]
      then
        # Get environment GitHub team slugs
        teams=$(jq -r --arg e "${env}" '.environments[] | select( .name == $e ) | .access[].github_slug' $json_file)
        echo "Teams for $environment: $teams"
        # Check if the environment exists and if it has a team associated with it
        environment_exists="false"
        check_if_environment_exists "${environment}"
        change_to_application_json="false"
        check_if_change_to_application_json "${environment}"
        
        if ([ "${environment_exists}" == "true" ] || [ "${teams}" == "" ]) && [ "${change_to_application_json}" == "false" ]
        then
          echo "${environment} already exists and there are no changes, or no GitHub team has been assigned, skipping..."
        else
          echo "Creating environment ${environment}"
          # Get GitHub team IDs
          team_ids=()
          for team in ${teams}
          do
            get_github_team_id ${team}
          done

          # Create reviewers JSON
          reviewers_json=""
          create_reviewers_json "${team_ids[@]}"  # Pass team IDs as arguments

          # Extract the optional additional reviewer from the JSON configuration
          additional_reviewers=$(jq -r --arg env "${env}" '.environments[] | select(.name == $env) | .additional_reviewers' "${json_file}")

          # Pass the correct variables to create_environment
          create_environment ${environment} "${reviewers_json}" "${additional_reviewers}"
        fi
      else
        echo "${environment} is a core environment, skipping..."
      fi
    done
  done
}

main
