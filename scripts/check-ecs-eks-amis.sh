#!/bin/bash

# Set values
export AWS_PAGER=""
regions="eu-west-2"
ROOT_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ROOT_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ROOT_AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN

ROLE_NAME="ModernisationPlatformAccess"
OUTDATED_AMIS_FILE="outdated-amis.csv"

# Initialize the file with headers
echo "Account Name,Region,Instance ID,Service Type (ECS/EKS),AMI ID" > $OUTDATED_AMIS_FILE

# Assume Role Function
getAssumeRoleCfg() {
    account_id=$1
    echo "Assuming role for account: $account_id"
    aws sts assume-role --role-arn "arn:aws:iam::${account_id}:role/${ROLE_NAME}" --role-session-name "check-outdated-ami" --output json > credentials.json
    export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' credentials.json)
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' credentials.json)
    export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' credentials.json)
}

# Function to get the latest ECS and EKS AMIs from SSM Parameter Store
get_latest_ami_ids() {
    latest_ecs_ami=$(aws ssm get-parameter --name "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended" --query 'Parameter.Value' --output text | jq -r '.image_id')
    latest_eks_ami=$(aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id" --query 'Parameter.Value' --output text)
    echo "$latest_ecs_ami $latest_eks_ami"
}

# Main logic
for account_id in $(jq -r '.account_ids | to_entries[] | "\(.value)"' <<< "$ENVIRONMENT_MANAGEMENT"); do
    echo "Processing account: $account_id"
    getAssumeRoleCfg "$account_id"

    for region in $regions; do
        echo "Region: $region"
        AWS_REGION=$region
        account_name=$(jq -r ".account_ids | to_entries[] | select(.value==\"$account_id\").key" <<< "$ENVIRONMENT_MANAGEMENT")

        # Get latest ECS and EKS AMIs
        read latest_ecs_ami latest_eks_ami < <(get_latest_ami_ids)
        echo "Latest ECS AMI: $latest_ecs_ami, Latest EKS AMI: $latest_eks_ami"

        #### 1. Check EC2 Instances backing ECS clusters ####
        ecs_clusters=$(aws ecs list-clusters --query 'clusterArns' --output text)
        for ecs_cluster in $ecs_clusters; do
            echo "Checking ECS cluster: $ecs_cluster"
            ecs_instances=$(aws ecs list-container-instances --cluster "$ecs_cluster" --query 'containerInstanceArns' --output text)

            if [[ -z "$ecs_instances" ]]; then
                echo "No ECS instances found in $ecs_cluster."
            else
                for ecs_instance_arn in $ecs_instances; do
                    ecs_instance_id=$(aws ecs describe-container-instances --cluster "$ecs_cluster" --container-instances $ecs_instance_arn --query 'containerInstances[0].ec2InstanceId' --output text)
                    ecs_ami_id=$(aws ec2 describe-instances --instance-ids $ecs_instance_id --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].ImageId' --output text)
                    if [[ "$ecs_ami_id" != "$latest_ecs_ami" && -n "$ecs_ami_id" ]]; then
                        echo "$account_name,$region,$ecs_instance_id,ECS,$ecs_ami_id,amazon-linux-2" >> $OUTDATED_AMIS_FILE
                    fi
                done
            fi
        done

        #### 2. Check EC2 Instances in EKS Node Groups ####
        eks_clusters=$(aws eks list-clusters --query 'clusters' --output text)
        for eks_cluster in $eks_clusters; do
            echo "Checking EKS cluster: $eks_cluster"
            eks_node_groups=$(aws eks list-nodegroups --cluster-name "$eks_cluster" --query 'nodegroups' --output text)

            if [[ -z "$eks_node_groups" ]]; then
                echo "No EKS node groups found in $eks_cluster."
            else
                for eks_node_group in $eks_node_groups; do
                    # Get EC2 instances associated with the node group
                    eks_instance_ids=$(aws ec2 describe-instances --filters "Name=tag:eks:nodegroup-name,Values=$eks_node_group" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text)
                    if [[ -z "$eks_instance_ids" ]]; then
                        echo "No running EKS instances found in node group $eks_node_group."
                    else
                        for eks_instance_id in $eks_instance_ids; do
                            eks_ami_id=$(aws ec2 describe-instances --instance-ids $eks_instance_id --query 'Reservations[*].Instances[*].ImageId' --output text)
                            if [[ "$eks_ami_id" != "$latest_eks_ami" ]]; then
                                echo "$account_name,$region,$eks_instance_id,EKS,$eks_ami_id,amazon-linux-2" >> $OUTDATED_AMIS_FILE
                            fi
                        done
                    fi
                done
            fi
        done
    done

    # Reset credentials after each account
    export AWS_ACCESS_KEY_ID=$ROOT_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$ROOT_AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN=$ROOT_AWS_SESSION_TOKEN
    rm credentials.json
done