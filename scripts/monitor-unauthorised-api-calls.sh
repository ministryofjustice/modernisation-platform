#!/bin/bash

# Set Values
export AWS_PAGER=""
regions="eu-west-2"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

# Create csv file
echo "Account ID,Account Name,Trigger Count, Max sum, Max sum timestamp, Top Event Name, Occurrences" > unauthorized-api-calls.csv

# Assume Role Function
getAssumeRoleCfg() {
    account_id=$1
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/ModernisationPlatformAccess" --role-session-name "test" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

for account_id in $(jq -r '.account_ids | to_entries[] | "\(.value)"' <<< $ENVIRONMENT_MANAGEMENT); do
    echo "account: $account_id"
    getAssumeRoleCfg "$account_id"
    for region in $regions; do
        # Set Values
        AWS_REGION=$region
        account_name=$(jq -r ".account_ids | to_entries[] | select(.value==\"$account_id\").key" <<< $ENVIRONMENT_MANAGEMENT)

        # Check for unauthorised-api-calls cloudwatch alarm triggers
        echo "Searching for unauthorised-api-calls alarm triggers in $account_name $region"

        count=$(aws cloudwatch describe-alarm-history \
                --alarm-name "unauthorised-api-calls" \
                --start-date $(date --date='7 days ago' -u "+%Y-%m-%dT%H:%M:%SZ") \
                --end-date $(date -u "+%Y-%m-%dT%H:%M:%SZ") \
                --query "AlarmHistoryItems[?HistorySummary=='Alarm updated from OK to ALARM'].Timestamp" \
                --output text | wc -l)

        echo "The alarm transitioned from OK to ALARM $count times in the last 7 days."

        # Find out the maximum sum of unauthorised-api-calls in the last 3 days within any 3 minute period
        result=$(aws cloudwatch get-metric-statistics \
                --namespace "LogMetrics" \
                --metric-name "unauthorised-api-calls" \
                --start-time $(date --date='3 days ago' -u "+%Y-%m-%dT%H:%M:%SZ") \
                --end-time $(date -u "+%Y-%m-%dT%H:%M:%SZ") \
                --period 180 \
                --statistics Sum \
                --query "Datapoints | sort_by(@, &Sum) | [].[Timestamp, Sum]" \
                --output text)

        # Extract the last row's sum and timestamp (this should be the max sum)
        max_sum=$(echo "$result" | tail -n 1 | awk '{print $2}')
        timestamp=$(echo "$result" | tail -n 1 | awk '{print $1}')

        # Output the results
        echo "Max Sum: $max_sum"
        echo "Timestamp: $timestamp"

        # Query the most commonly occurring eventName in the logs
        log_group_name="cloudtrail"
        query_string="fields @timestamp, eventName | filter errorCode = 'UnauthorizedOperation' or (errorCode = 'AccessDenied' and eventName not in ['ListDelegatedAdministrators', 'GetMacieSession']) | stats count(*) as occurrences by eventName | sort occurrences desc | limit 1"
        query_id=$(aws logs start-query \
            --log-group-name "$log_group_name" \
            --start-time $(date --date='7 days ago' +%s) \
            --end-time $(date +%s) \
            --query-string "$query_string" \
            --query "queryId" \
            --output text)

        # Wait for the query to complete
        sleep 10

        # Get the query results
        query_result=$(aws logs get-query-results --query-id "$query_id")

        # Extract the most common eventName and occurrences
        common_event_name=$(echo "$query_result" | jq -r '.results[0][0].value')
        occurrences=$(echo "$query_result" | jq -r '.results[0][1].value')

        echo "Most Common Event Name: $common_event_name"
        echo "Occurrences: $occurrences"

        # Write to csv file
        echo "$account_id,$account_name,$count,$max_sum,$timestamp,$common_event_name,$occurrences" >> unauthorized-api-calls.csv

        export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
        export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
        rm credentials.json
    done
done