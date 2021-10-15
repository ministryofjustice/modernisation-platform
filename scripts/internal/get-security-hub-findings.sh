#!/bin/bash

# Description
# Script to get security hub findings across the modernisation platform accounts and collect them into a single file for inspection
# Generates a tsv file containing all the findings
# Script assumes the same named role in each account to read security hub information
# See https://docs.aws.amazon.com/cli/latest/reference/securityhub/get-findings.html#examples for info about the security hub findings filters

# Parameters
# - Name of the profile in your aws config file representing access to the mod platform account (this profile is most likely based on a role ARN that has sufficient permissions to be able to read secret values)

# Dependencies
# - Ensure this script can be run - chmod u+x get-security-hub-findings.sh
# - jq - required to parse the json contained in the secret containing the account ids
# - aws-vault - required to dynamically connect to different accounts

# Examples
# ./get-security-hub-findings.sh mod

# Setup: set script constants
aws_profile_name_mod_platform=$1
output_file_name="findings.tsv"
temp_files_dir="tempfiles"
findings_filter='{"SeverityLabel":[{"Value":"CRITICAL","Comparison":"EQUALS"}],"WorkflowStatus":[{"Value":"NEW","Comparison":"EQUALS"},{"Value":"NOTIFIED","Comparison":"EQUALS"}],"RecordState":[{"Value":"ACTIVE","Comparison":"EQUALS"}]}'

# Setup: Create function that gets security hub findings for an account and writes to temp tile
function getFindingsForAccount()  {
  alias=$1
  id=$2
  echo "Getting security hub findings for account with alias $alias and with id $id"
  export AWS_ROLE_ARN="arn:aws:iam::$id:role/ModernisationPlatformAccess"
  export AWS_ROLE_SESSION_NAME="$alias"
  aws-vault exec $aws_profile_name_mod_platform -- aws securityhub get-findings --filters $findings_filter --query "Findings[*].[AwsAccountId,Title,Description,Types[0],Severity.Label]" --output text \
    | sed "s/$id/$id\t$alias/g" > $temp_files_dir/$id.tsv
}

# Setup: remove final output file if it exists and create temp folder
if [[ -f $output_file_name ]]; then
  rm $output_file_name
fi
if [[ ! -d $temp_files_dir ]]; then
  mkdir $temp_files_dir 
else 
  rm $temp_files_dir/*.tsv
fi

# Check inputs
if [[ $# -ne 1 ]]; then
  echo "This script expects a single argument - the aws config profile name representing the mod platform account"
  exit 1
fi

# Get account ids from secret
secret=$(aws-vault exec $aws_profile_name_mod_platform -- aws secretsmanager get-secret-value --secret-id environment_management --query "SecretString" --output text)
accountAliases=$(jq -r '.account_ids|keys|.[]' <<< "$secret")

# Loop over accounts to get findings
for accountAlias in $accountAliases; do
  accountId=$(jq -r ".account_ids[\"$accountAlias\"]" <<< "$secret")
  getFindingsForAccount $accountAlias $accountId
done

# Generate final file
echo -e "AwsAccountId\tAwsAccountAlias\tTitle\tDescription\tType\tSeverity\tLabel" > $output_file_name
for filepath in $temp_files_dir/*; do
  filename=$(basename $filepath)
  cat $temp_files_dir/$filename >> $output_file_name
done

# Cleanup - remove temp files folder
if [[ -d $temp_files_dir ]]; then
  rm -rf $temp_files_dir
fi
