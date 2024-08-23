#!/bin/bash

echo "Installing tools required"
apt-get update
apt-get -y install python-pip
apt-get -y install unzip
pip install --upgrade pip
pip install ansible
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

echo "Installing node using nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. /.nvm/nvm.sh
nvm install node

echo "Updating hosts"
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "$PRIVATE_IP	${smtp_host_domain}		smtp-${inventory_env}" >> /etc/hosts
hostname -b 
mkdir -p /root/ansible

echo "Getting secrets from Secrets Manager"
export SESP=`/usr/local/bin/aws --region eu-west-2 secretsmanager get-secret-value --secret-id laa-postfix/APP_DATA_MIGRATION_SMTP_PASSWORD --query SecretString --output text`
export SESU=`/usr/local/bin/aws --region eu-west-2 secretsmanager get-secret-value --secret-id laa-postfix/APP_DATA_MIGRATION_SMTP_USER --query SecretString --output text`
export SESANS=`/usr/local/bin/aws --region eu-west-2 secretsmanager get-secret-value --secret-id laa-postfix/SESANS --query SecretString --output text`
# mkdir -p /run/cfn-init # Path to store cfn-init scripts

echo "Running Ansible Pull"
ansible-pull -U https://$SESANS@github.com/ministryofjustice/laa-aws-postfix-smtp aws/app/ansible/adhoc.yml -C modernisation-platform -i aws/app/ansible/inventory/${inventory_env} --limit=smtp --extra-vars "smtp_user_name=${smtp_user_name} smtp_user_pass=${smtp_user_pass}" -d /root/ansible | tail -n +3
