#!/bin/bash

set -o pipefail
set -e

instance_arn=$(aws sso-admin list-instances --query 'Instances[*].InstanceArn' --output text)
permission_sets=$(aws sso-admin list-permission-sets --instance-arn $instance_arn  --query 'PermissionSets[*]' --output text)

for permission_set in $permission_sets; do
	description=$(aws sso-admin describe-permission-set --instance-arn $instance_arn --permission-set-arn $permission_set)
	name=$(echo $description | jq -r '.PermissionSet.Name')
	arn=$(echo $description | jq -r '.PermissionSet.PermissionSetArn')
	if [[ $name == modernisation-platform* ]];then
		echo "Updating permission set $name"

		# Capture the aws-cli output as a variable, rather than blocking the next task
		output=$(aws sso-admin provision-permission-set --instance-arn $instance_arn --permission-set-arn $arn --target-type ALL_PROVISIONED_ACCOUNTS --output json)
		echo $output
	fi
done
