#/bin/bash

set -Eeo pipefail

environment=$1

# Check for changes in environments-networks
accounts=$(git diff --no-commit-id --name-only --diff-filter=AM -r @^ | awk '{print $1}' | grep "environments-networks/.*.json" | xargs -I {} cat {} | jq '.cidr.subnet_sets[].accounts[]' -r | grep "\-${TF_ENV}" | uniq | tr \\n " ")
echo "[+] -----------------------------------------------------------------"
echo "[+] environments-networks accounts to run RAM share on: ${accounts}"

if [ ! -z "${accounts}" ]; then
  for account in ${accounts}; do
    application=`echo ${account} | sed -e "s/-${environment}//g"`
    echo "[+] *********************************************"
    echo "[+] Starting up RAM association for account ${account} of application ${application}"
    networking_file="./terraform/environments/${application}/networking.auto.tfvars.json"
    # check if the required networking file exists
    if [ -f "${networking_file}" ]; then
      echo "[+] ${networking_file} exists, running RAM share."
      bash scripts/member-account-ram-association.sh ${application} ${environment}
    else 
      echo "[+] ${networking_file} does not exist, skipping RAM share."
    fi
  done
else
  echo "[+] There were no member accounts to process"
  exit 0
fi

# check for changes to networking.auto.tfvars.json files
changed_networking_files=$(git diff --no-commit-id --name-only --diff-filter=AM -r @^ | grep "networking.auto.tfvars.json")
echo "[+] -----------------------------------------------------------------"
echo "[+] networking.auto.tfvars.json changed files: ${changed_networking_files}"

application=""

if [ ! -z "${changed_networking_files}" ]; then
  for file in ${changed_networking_files}; do
    echo "[+] *********************************************"
    application=${file#"terraform/environments/"}
    application=${application%"/networking.auto.tfvars.json"}
    echo "[+] Starting up RAM association for application ${application}"
    bash scripts/member-account-ram-association.sh ${application} ${environment}
  done
else
  echo "[+] There were no networking.auto.tfvars.json changed files"
  exit 0
fi
