#/bin/bash

environment=$1

# Check for changes in environments-networks
accounts=$(git diff --no-commit-id --name-only --diff-filter=AM -r @^ | awk '{print $1}' | grep "environments-networks/.*.json" | xargs -I {} cat {} | jq '.cidr.subnet_sets[].accounts[]' -r | grep "\-${TF_ENV}" | uniq | tr \\n " ")
echo "[+] -----------------------------------------------------------------"
echo "[+] environments-networks accounts to run RAM share on: ${accounts}"

if [ ! -z "${accounts}" ]; then
  for account in ${accounts}; do
    # Extract application and environment from account name
    # Try known environment suffixes in order of specificity
    account_environment=""
    application=""
    
    for env_suffix in "development" "preproduction" "production" "test" "sandbox"; do
      if [[ "${account}" == *-${env_suffix} ]]; then
        account_environment="${env_suffix}"
        application="${account%-${env_suffix}}"
        break
      fi
    done
    
    # Fallback if no match (shouldn't happen with valid account names)
    if [ -z "${account_environment}" ]; then
      echo "[+] WARNING: Could not extract environment from ${account}, skipping"
      continue
    fi
    
    echo "[+] *********************************************"
    echo "[+] Starting up RAM association for account ${account}"
    echo "[+] Application: ${application}, Account environment: ${account_environment}, VPC workspace: ${environment}"
    networking_file="./terraform/environments/${application}/networking.auto.tfvars.json"
    # check if the required networking file exists
    if [ -f "${networking_file}" ]; then
      echo "[+] ${networking_file} exists, running RAM share."
      bash scripts/member-account-ram-association.sh ${application} ${account_environment}
    else 
      echo "[+] ${networking_file} does not exist, skipping RAM share."
    fi
  done
else
  echo "[+] There were no member accounts to process"
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
fi

exit 0
