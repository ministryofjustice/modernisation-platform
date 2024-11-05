# This bash script get the URL for each failed workflow action in Modernisation Platform repo as follows:
# - Gets all completed workflows that completed as defined by the $REPORTING_PERIOD variable.
# - Of those, finds the latest failed action only. Ignores any previously failed actions,
# - Ignores failed actions that have had a subsequent successful action,

# The GitHub API expects dates in ISO 8601 format for filtering parameters like created or updated.
# We want the period as defined in the $REPORITNG_PERIOD variable. We use $formatted_date for readibility.
period=$(date -u --date="$REPORTING_PERIOD hours ago" +"%Y-%m-%dT%H:%M:%SZ")
formatted_date=$(date -d "$period" +"%d-%m-%Y %H:%M:%S")
echo "Getting all workflows that completed since $formatted_date"

# The updated_at field provides the finished date so we check against that.
# The created field is for all actions that have completed including those that have failed.
# Also returns only those workflows run from the main branch.
GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPO/actions/runs?created=>=$period&status=completed&branch=main"
response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL")

# Due to an issue with how the github api uses the updated_at filter, this is added to ensure that the json doesn't included workflows completed before $period.
#filtered_workflows=$(echo "$response" | jq --arg period "$PERIOD" '.workflow_runs | map(select(.updated_at >= $period))')

# This section iterates through each of the workflows returned above, sorts in asc date order and looks for those that have the conclusion status of failure.
recent_failures=$(echo "$response" | jq -r '
  # Group by workflow name
  .workflow_runs | group_by(.name) | 
  map(
    # Sort each group by created_at in descending order (newest first)
    sort_by(.created_at) | reverse |
    
    # Check if there is a failure without any subsequent success
    if (map(select(.conclusion == "success")) | length) == 0 
      or (first(.[] | select(.conclusion == "failure")) as $failure |
          .[0: index($failure)] | map(select(.conclusion == "success")) | length) == 0
    then 
      # Output the latest failure in the group if no subsequent success
      first(.[] | select(.conclusion == "failure")) | 
      {name: .name, url: .html_url, status: .conclusion, created_at: .created_at}
    else empty end
  ) 
  # Filter out any empty results and ensure only valid objects are output
  | map(select(.name and .url and .status and .created_at))
')

# Added this to control whether the subsequent steps are run.
sendreport="true"

# This checks the contents of $recent_failures and if not empty it saves the variable to a file for use in the next step.
if [[ "$recent_failures" == "[]" ]]; then
  echo "No workflow failures without subsequent successful completion that finished since $formatted_date ." 
elif [[ -n "$recent_failures" ]]; then
  echo "Most recent failed GitHub Actions without subsequent success that finished since $formatted_date :"
  echo "$recent_failures" > recent_failures.json
  cat recent_failures.json
else
  echo "ERROR generating failed workflows list ."
  # This ensures that the subsequent steps are not run.
  sendreport="false"
  exit 1
fi

echo "sendreport=$sendreport" >> $GITHUB_OUTPUT

# Sends the formatted_date variable to the output to be used in the slack message.
if [ "$sendreport" == "true" ]; then
  echo "formatted_date=$formatted_date" >> $GITHUB_OUTPUT
fi