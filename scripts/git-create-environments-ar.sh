#!/bin/bash

set -e

github_org="ministryofjustice"
repository="${github_org}/modernisation-platform-environments"
secret=$TERRAFORM_GITHUB_TOKEN

# Get all existing GitHub environments
get_existing_environments() {
  page=1
  github_environments=""

  while :; do
    response=$(curl -si \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token ${secret}" \
      "https://api.github.com/repos/${repository}/environments?per_page=100&page=${page}")

    headers=$(echo "$response" | awk 'BEGIN {RS="\r\n\r\n"} NR==1 {print}')
    body=$(echo "$response" | awk 'BEGIN {RS="\r\n\r\n"} NR==2 {print}')

    current_page_environments=$(echo "$body" | jq -r '.environments[].name')
    github_environments="${github_environments} ${current_page_environments}"

    next_link=$(echo "$headers" | grep -i '^link:' | sed -n 's/.*<\(.*\)>; rel="next".*/\1/p')
    [ -z "$next_link" ] && break
    page=$((page + 1))
  done

  echo "Existing GitHub environments: $github_environments"
}

# Get GitHub team ID
get_github_team_id() {
  team_slug=${1}
  response=$(curl -s \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${secret}" \
    "https://api.github.com/orgs/${github_org}/teams/${team_slug}")
  echo "${response}" | jq -r '.id'
}

# Get GitHub user ID
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
  changed_envs=$(git diff --name-only origin/main...HEAD \
    | grep "^environments/.*\.json$" \
    | sed 's|environments/\(.*\)\.json|\1|' \
    | uniq)

  echo "Changed json files=$changed_envs"
  application_name=$(echo $1 | sed 's/-[^-]*$//')
  echo "Application name: $application_name"

  if [[ $changed_envs =~ (^|[[:space:]])$application_name($|[[:space:]]) ]]; then
    change_to_application_json="true"
  else
    change_to_application_json="false"
  fi
  echo "Change to application json: $change_to_application_json"
}

# Create environment with reviewers
create_environment() {
  local environment_name=$1
  local reviewers_json=$2
  
  echo "Creating/updating environment: ${environment_name}"
  
  if [ "${env}" == "preproduction" ] || [ "${env}" == "production" ]; then
    payload="{\"deployment_branch_policy\":{\"protected_branches\":true,\"custom_branch_policies\":false},\"reviewers\": [${reviewers_json}]}"
  else
    payload="{\"reviewers\": [${reviewers_json}]}"
  fi

  if [ "${DRY_RUN}" == "true" ]; then
    echo "DRY RUN - Would send payload:"
    echo "$payload" | jq
    echo "DRY RUN - No changes made"
  else
    response=$(echo "${payload}" | curl -L -s -i \
      -X PUT \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${secret}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "https://api.github.com/repos/${repository}/environments/${environment_name}" \
      -d @-)
    
    if echo "$response" | grep -q "HTTP/.* 200"; then
      echo "Successfully updated environment ${environment_name}"
    else
      echo "Error updating environment ${environment_name}"
      echo "API Response:"
      echo "$response"
    fi
  fi
}

# Create reviewers JSON for teams
create_team_reviewers_json() {
  local team_ids=("${@}")
  local reviewers_json=""

  for id in "${team_ids[@]}"
  do
    if [ -n "$id" ] && [ "$id" != "null" ]; then
      raw_jq=$(jq -cn --arg team_id "$id" '{ "type": "Team", "id": ($team_id|tonumber) }')
      reviewers_json="${reviewers_json}${raw_jq},"
    fi
  done

  echo "${reviewers_json}" | sed 's/,$//'
}

# Create reviewers JSON for users
create_user_reviewers_json() {
  local user_ids=("${@}")
  local reviewers_json=""

  for id in "${user_ids[@]}"
  do
    if [ -n "$id" ] && [ "$id" != "null" ]; then
      raw_jq=$(jq -cn --arg user_id "$id" '{ "type": "User", "id": ($user_id|tonumber) }')
      reviewers_json="${reviewers_json}${raw_jq},"
    fi
  done

  echo "${reviewers_json}" | sed 's/,$//'
}

log_step() {
  echo -e "\n\033[1;33m==> $1\033[0m"
}

log_block() {
  echo -e "\n\033[1;32m***********************************************\033[0m"
  echo -e "\033[1;32m$1\033[0m"
  echo -e "\033[1;32m***********************************************\033[0m"
}


# Prepares reviewer configuration (teams and users) for a GitHub environment
setup_environment_reviewers() {
  local environment_name=$1
  local json_file=$2
  local env=$3
  local application=$4
  local component_name=${5:-""}

  # Initialize teams variable
  teams=""

  # For component environments, first check if component has github_action_reviewer=true
  if [ -n "$component_name" ]; then
    echo "Checking component for github_action_reviewer=true..."
    component_reviewer_team=$(jq -r --arg c "${component_name}" '.components[] | select(.name == $c) | select(.github_action_reviewer=="true") | .sso_group_name' "$json_file")
        
    if [ -n "$component_reviewer_team" ] && [ "$component_reviewer_team" != "null" ]; then
      echo "Found component with github_action_reviewer=true: ${component_reviewer_team}"
      teams="$component_reviewer_team"
    fi
  fi

  # If no component reviewer team found, proceed with normal logic
  if [ -z "$teams" ]; then
    echo "No component reviewer team found, checking environment teams..."
    
    # Check if any environment access has github_action_reviewer=true
    reviewer_teams=$(jq -r --arg e "${env}" '.environments[] | select(.name == $e) | .access[] | select(.github_action_reviewer=="true") | .sso_group_name' "$json_file")

    if [ -n "$reviewer_teams" ]; then
      echo "Found teams with github_action_reviewer=true"
      teams="$reviewer_teams"
    else
      echo "No teams with github_action_reviewer=true found"
      
      # Add component team if exists (without github_action_reviewer requirement)
      if [ -n "$component_name" ]; then
        component_team=$(jq -r --arg c "${component_name}" '.components[] | select(.name == $c) | .sso_group_name' "$json_file")
        if [ -n "$component_team" ] && [ "$component_team" != "null" ]; then
          echo "Using component team: ${component_team}"
          teams="$component_team"
        else
          echo "No component team defined"
        fi
      fi
      
      # Add all environment teams
      env_teams=$(jq -r --arg e "${env}" '.environments[] | select(.name == $e) | .access[].sso_group_name' "$json_file")
      if [ -n "$env_teams" ]; then
        teams="$teams $env_teams"
      fi
    fi
  fi

  # Remove duplicates and clean up spaces
  teams=$(echo "$teams" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

  # Filter out Azure teams
  filtered_teams=""
  for team in $teams; do
    if [[ ! $team == azure-aws-sso* ]]; then
      filtered_teams+="$team "
    fi
  done

  filtered_teams=$(echo $filtered_teams | xargs)
  echo "Teams after Azure filtering: ${filtered_teams}"

  if [ -z "$filtered_teams" ]; then
    echo "No non-Azure teams available, skipping environment creation"
    return
  fi

  # Rest of the function remains the same...
  # Get GitHub team ids
  team_ids=()
  for team in ${filtered_teams}; do
    team=$(echo "${team}" | xargs)
    team_id=$(get_github_team_id "${team}")
    if [ -n "$team_id" ] && [ "$team_id" != "null" ]; then
      team_ids+=("$team_id")
    else
      echo "Warning: Team not found - ${team}"
    fi
  done

  # Get additional reviewers
  additional_reviewers=($(jq -r --arg e "${env}" '.environments[] | select(.name == $e) | .additional_reviewers // [] | .[]' "${json_file}"))
  user_ids=()
  for reviewer in "${additional_reviewers[@]}"; do
    user_id=$(get_github_user_id "${reviewer}")
    if [ -n "$user_id" ] && [ "$user_id" != "null" ]; then
      user_ids+=("$user_id")
    else
      echo "Warning: User not found - ${reviewer}"
    fi
  done

  # Create reviewers JSON
  team_reviewers_json=$(create_team_reviewers_json "${team_ids[@]}")
  user_reviewers_json=$(create_user_reviewers_json "${user_ids[@]}")
  
  reviewers_json=""
  if [ -n "$team_reviewers_json" ] && [ -n "$user_reviewers_json" ]; then
    reviewers_json="${team_reviewers_json},${user_reviewers_json}"
  elif [ -n "$team_reviewers_json" ]; then
    reviewers_json="${team_reviewers_json}"
  elif [ -n "$user_reviewers_json" ]; then
    reviewers_json="${user_reviewers_json}"
  fi

  # Create/update environment
  create_environment "${environment_name}" "${reviewers_json}"
  echo "=== Finished processing ${environment_name} ==="
  echo
}

# Creates the environment if it doesn't exist or if the config has changed
create_environment_if_required() {
  local environment_name=$1
  local json_file=$2
  local env=$3
  local application=$4
  local component_name=${5:-""}

  log_step "Processing environment: ${environment_name}"
  check_if_environment_exists "${environment_name}"
  check_if_change_to_application_json "${application}"

  if [ "${environment_exists}" == "true" ] && [ "${change_to_application_json}" == "false" ]; then
    echo "${environment_name} already exists and there are no changes skipping..."
  else
    setup_environment_reviewers "${environment_name}" "${json_file}" "${env}" "${application}" "${component_name}"
  fi
}

# Main function
main() {
  get_existing_environments

  for json_file in ./environments/*.json; do
    log_block "Processing file: ${json_file}"
    application=$(basename "${json_file}" .json)
    # Check if components exist
    components_exist=$(jq -e '.components' "${json_file}" >/dev/null 2>&1; echo $?)
    
    for env in $(jq -r --arg FILENAME "${application}" '.environments[].name' "${json_file}"); do
      account_type=$(jq -r '."account-type"' "${json_file}")
      if [ "${account_type}" = "member" ]; then
        # Process base environment
        base_environment="${application}-${env}"
        create_environment_if_required "${base_environment}" "${json_file}" "${env}" "${application}"

        # Process component environments if they exist
        if [ "$components_exist" -eq 0 ]; then
          jq -r '.components[].name' "${json_file}" | while read -r component_name; do
            component_environment="${application}-${env}-${component_name}"
            echo
            create_environment_if_required "${component_environment}" "${json_file}" "${env}" "${application}" "${component_name}"
          done
        fi
      else
        echo "${application}-${env} is a core environment, skipping..."
      fi
    done
  done
}

main