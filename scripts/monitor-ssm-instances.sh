#!/bin/bash
export AWS_PAGER=""

#Create csv file
echo "Account ID,Account Name, Instance ID,Instance Name,SSM Status" > ssm-managed-instances.csv

#Set Values
account_name=$(aws iam list-account-aliases --query 'AccountAliases[*]' --output text)
account_id=$(aws sts get-caller-identity --query Account --output text)

#Check for SSM managed instances
for instance in $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
do
    instance_name=$(aws ec2 describe-instances --instance-ids $instance --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value]' --output text)
    managed=$(aws ssm describe-instance-information  --filters "Key=InstanceIds,Values=$instance" --query 'InstanceInformationList[*].[AssociationStatus]' --output text)
    if [[ "$managed" != "Success" ]]; then 
        managed="Not Managed";
    else
        managed="Managed"
    fi
    echo "$account_id,$account_name,$instance,$instance_name,$managed" >> ssm-managed-instances.csv
done