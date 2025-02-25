#!/bin/bash

set -e

github_org="ministryofjustice"
repository="${github_org}/modernisation-platform-environments"
secret=$TERRAFORM_GITHUB_TOKEN

get_existing_environments() {
  page=1
  github_environments=""

  while :; do
    response=$(curl -si \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${secret}" \
      "https://api.github.com/repos/${repository}/environments?per_page=100&page=${page}")

    # Separate headers and body using awk
    headers=$(echo "$response" | awk 'BEGIN {RS="\r\n\r\n"} NR==1 {print}')
    body=$(echo "$response" | awk 'BEGIN {RS="\r\n\r\n"} NR==2 {print}')

    # Debug output to see the headers and body
    # echo "Headers for page ${page}:"
    # echo "${headers}"
    # echo "Body for page ${page}:"
    # echo "${body}"

    current_page_environments=$(echo "$body" | jq -r '.environments[].name')
    if [ $? -ne 0 ]; then
      echo "jq error: Failed to parse JSON"
      exit 1
    fi

    github_environments="${github_environments} ${current_page_environments}"

    # Check if there's a "next" link in the headers
    next_link=$(echo "$headers" | grep -i '^link:' | sed -n 's/.*<\(.*\)>; rel="next".*/\1/p')

    if [ -z "$next_link" ]; then
      break  # No more pages to fetch
    else
      page=$((page + 1))
    fi
  done

  echo "Existing GitHub environments: $github_environments"
}

get_github_team_id() {
  team_slug=${1}
  response=$(curl -s \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${secret}" \
    https://api.github.com/orgs/${github_org}/teams/${team_slug})
  echo "${response}" | jq -r '.id'
}

get_github_user_id() {
  username=$1
  response=$(curl -s \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${secret}" \
    "https://api.github.com/users/${username}")
  echo "${response}" | jq -r '.id'
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
  reviewers_json=$2  # Accept the reviewers_json parameter
  
  echo "Creating environment ${environment_name}..."
  # echo "Teams for payload: ${github_teams}"
  if [ "${env}" == "preproduction" ] || [ "${env}" == "production" ]
  then
    # Include both github_teams and additional_reviewers in the payload
    payload="{\"deployment_branch_policy\":{\"protected_branches\":true,\"custom_branch_policies\":false},\"reviewers\": [${reviewers_json}]}"
  else
    # Include both github_teams and additional_reviewers in the payload
    payload="{\"reviewers\": [${reviewers_json}]}"
  fi

  if [ "${DRY_RUN}" == "true" ]; then
    echo "DRY Run Payload: $payload"
    echo "Repository: ${repository}"
    echo "DRY Run Only no payload submission to GitHub API"

  else
    echo "Payload: $payload"
    echo "Repository: ${repository}"
    response=$(echo "${payload}" | curl -L -s -i \
      -X PUT \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${secret}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/${repository}/environments/${environment_name}\
      -d @- > /dev/null 2>&1)

  echo "API Response: $response"  # Print the API response
  fi
}

create_team_reviewers_json() {
  local team_ids=("${@}")
  local reviewers_json=""

  for id in "${team_ids[@]}"
  do
    raw_jq=$(jq -cn --arg team_id "$id" '{ "type": "Team", "id": ($team_id|tonumber) }')
    reviewers_json="${reviewers_json}${raw_jq},"
  done

  reviewers_json=$(echo "${reviewers_json}" | sed 's/,$//')
  echo "${reviewers_json}"
}

create_user_reviewers_json() {
  local user_ids=("${@}")
  local reviewers_json=""

  for id in "${user_ids[@]}"
  do
    raw_jq=$(jq -cn --arg user_id "$id" '{ "type": "User", "id": ($user_id|tonumber) }')
    reviewers_json="${reviewers_json}${raw_jq},"
  done

  reviewers_json=$(echo "${reviewers_json}" | sed 's/,$//')
  echo "${reviewers_json}"
}

create_reviewers_json() {
  local reviewers_json=""

  reviewers_json="${team_reviewers_json},${user_reviewers_json}"

  # Remove trailing comma
  reviewers_json=$(echo "${reviewers_json}" | sed 's/,$//')

  echo "${reviewers_json}"
}

main() {
  # Load existing GitHub environments
  get_existing_environments
  # Loop through each application.json file
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
        # Check for teams that have the github_action_reviewer flag set to true
        teams=$(jq -r --arg e "${env}" '.environments[] | select( .name == $e ) | .access[] | select(.github_action_reviewer=="true") | .sso_group_name' $json_file)
        # if teams is empty (none of the teams have the github_action_reviewer flag), get all teams
        if [ -z "$teams" ]; then
          teams=$(jq -r --arg e "${env}" '.environments[] | select( .name == $e ) | .access[].sso_group_name' $json_file)
        fi

        echo "Teams for $environment: $teams"

        # Filter out Azure teams (those starting with "azure-aws-sso")
        filtered_teams=""
        for team in $teams; do
          if [[ ! $team == azure-aws-sso* ]]; then
            filtered_teams+="$team "
          else
            echo "Skipping Azure team: $team"
          fi
        done

        # Trim trailing whitespace
        filtered_teams=$(echo $filtered_teams | xargs)

        if [ -z "$filtered_teams" ]; then
          echo "No non-Azure teams available for $environment, skipping..."
          continue
        fi

        # Check if environment exists and if it has a team associated with it
        environment_exists="false"
        check_if_environment_exists "${environment}"
        change_to_application_json="false"
        check_if_change_to_application_json "${environment}"
        
        if ([ "${environment_exists}" == "true" ] || [ "${filtered_teams}" == "" ]) && [ "${change_to_application_json}" == "false" ]
        then
          echo "${environment} already exists and there are no changes, or no valid GitHub team has been assigned, skipping..."
        else
          echo "Creating environment ${environment}"
          # Get GitHub team ids
          team_ids=()
          for team in ${filtered_teams}
          do
            team=$(echo "${team}" | xargs)  # Remove leading/trailing whitespace
            team_id=$(get_github_team_id "${team}")
            team_ids+=("${team_id}")
          done

          # Extract the optional additional reviewers from the JSON as strings
          additional_reviewers=($(jq -r --arg e "${env}" '.environments[] | select(.name == $e) | .additional_reviewers // []' "${json_file}" | tr -d \"))

          # Check if additional_reviewers is not empty before processing
          if [ ${#additional_reviewers[@]} -gt 0 ]; then
            echo "Additional Reviewers: ${additional_reviewers[*]}"

            # Fetch GitHub user IDs for additional reviewers
            user_ids=()
            for reviewer in "${additional_reviewers[@]}"
            do
              # Remove leading and trailing spaces and commas
              reviewer=$(echo "${reviewer}" | sed 's/^[[:space:],]*//;s/[[:space:],]*$//')

              if [ -n "${reviewer}" ] && [ "${reviewer}" != "[]" ]; then
                user_id=$(get_github_user_id "${reviewer}")
                if [ -n "${user_id}" ] && [ "${user_id}" != "null" ]; then
                  user_ids+=("${user_id}")
                else
                  echo "User not found or error occurred for reviewer: ${reviewer}. Skipping..."
                fi
              fi
            done
          fi

          # Create reviewers json
          reviewers_json=""
          # Create reviewers json for teams and users
          team_reviewers_json=$(create_team_reviewers_json "${team_ids[@]}")
          user_reviewers_json=$(create_user_reviewers_json "${user_ids[@]}")
          reviewers_json=$(create_reviewers_json "${team_reviewers_json}" "${user_reviewers_json}")
          create_environment ${environment} "${reviewers_json}"
        fi
      else
        echo "${environment} is a core environment, skipping..."
      fi
    done
  done
}

main
