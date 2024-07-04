#!/bin/bash

# AWS credentials for the MP account
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

# Get the current month and year
current_year=$(date +%Y)
current_month=$(date +%m)
previous_month_name=$(date -d "${current_month}/01 -1 month" +%B)
previous_month_year="$previous_month_name $current_year"

# S3 bucket and file details
bucket_name="mp-cost-explorer-reports"
csv_file="cost_explorer.csv"
s3_file_path="s3://$bucket_name/$csv_file"

# Get the start date of the previous month (1st of last month)
start_date=$(date -d "$current_year-$current_month-01 -1 month" +"%Y-%m-01")
# Get the end date as the current month's 1st
end_date=$(date -d "$current_year-$current_month-01" +"%Y-%m-01")

# Check if the CSV file exists in the S3 bucket
if aws s3 ls "$s3_file_path" > /dev/null 2>&1; then
    # Download the existing CSV file from S3
    aws s3 cp "$s3_file_path" "$csv_file"
else
    # Create a new CSV file with headers if it doesn't exist
    echo "Account Name,$previous_month_year" > "$csv_file"
fi

# Ensure the current month-year header is present
if ! head -n 1 "$csv_file" | grep -q "$previous_month_year"; then
    sed -i '' -e "1s/$/, $previous_month_year/" "$csv_file"
fi

getAssumeRoleCfg() {
    account_id=$1
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/ModernisationPlatformAccess" --role-session-name "test" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

# Temporary file to store updated CSV content
tmp_csv_file=$(mktemp)

# Copy header to the temporary file
head -n 1 "$csv_file" > "$tmp_csv_file"

for account_id in $(jq -r '.account_ids | to_entries[] | "\(.value)"' <<< $ENVIRONMENT_MANAGEMENT); do
    getAssumeRoleCfg "$account_id"
    account_name=$(jq -r ".account_ids | to_entries[] | select(.value==\"$account_id\").key" <<< $ENVIRONMENT_MANAGEMENT)
    cost=$(aws ce get-cost-and-usage --time-period Start=$start_date,End=$end_date --granularity MONTHLY --metrics "UnblendedCost" --output json | jq -r ".ResultsByTime[].Total.UnblendedCost.Amount")
    rounded_cost=$(echo "scale=2; $cost/1" | bc)
    echo "Processing account: $account_name"
    
    if grep -q "^$account_name," "$csv_file"; then
        # If the account name exists, update the cost for the current month
        if [ ! -z "$rounded_cost" ]; then
            # Find the column number for the current month-year
            column_number=$(head -n 1 "$csv_file" | tr ',' '\n' | grep -n "$previous_month_year" | cut -d ':' -f 1 || echo 0)
            # Update data in the corresponding column if column_number is valid
            if [ "$column_number" -gt 0 ]; then
                awk -v account="$account_name" -v col="$column_number" -v cost="$rounded_cost" -F, 'BEGIN {OFS=FS} $1 == account {$(col) = cost}1' "$csv_file" > tmpfile && mv tmpfile "$csv_file"
            fi
        fi
        # Add the updated account row to the temporary file
        grep "^$account_name," "$csv_file" >> "$tmp_csv_file"
    else
        # If the account name does not exist, add a new row
        # Get the number of columns in the header
        num_columns=$(head -n 1 "$csv_file" | awk -F, '{print NF}')
        # Create a new row with empty fields up to the current month column, then add the cost
        new_row="$account_name"
        for ((i=2; i<num_columns; i++)); do
            new_row="$new_row,"
        done
        new_row="$new_row,$rounded_cost"
        echo "$new_row" >> "$csv_file"
        # Add the new row to the temporary file
        echo "$new_row" >> "$tmp_csv_file"
    fi

    # Clean up: Restore original AWS credentials and delete temporary credentials file
    export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
    rm credentials.json
done
mv "$tmp_csv_file" "$csv_file"

# Upload the updated CSV file to S3
aws s3 cp "$csv_file" "$s3_file_path"
rm "$csv_file"