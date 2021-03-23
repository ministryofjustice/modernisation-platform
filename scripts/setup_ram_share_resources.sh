#!/bin/bash

basedir=terraform/environments

envs=("production" "preproduction" "test" "development")
#envs=("production")

application_name="$1"

setup_ram_share_core() {


  if [[ "$application_name" != " " ]]; then

    for env in "${envs[@]}"; do

      #Runs a Terraform plan/apply in the core-vpc-<env> to create the RAM share and association
      echo "[+] Selecting terraform workspace: core-vpc-$env"

      echo "[+] Running Terraform init"
      ./scripts/terraform-init.sh "$basedir/core-vpc"   
      
      # Select workspace
      workspace=$(terraform -chdir="$basedir/core-vpc" workspace select "core-vpc-${env}")
      
      if [[ "${workspace}" ]]; then

        echo "[+] Running Terraform plan"     
        # Run terraform plan
        ./scripts/terraform-plan.sh "$basedir/core-vpc"

        # Run terraform apply
        #./scripts/terraform-apply.sh $basedir/core-vpc
      fi
    done
        echo "[+] Finished running terraform across vpc-core accounts"
        echo "[+] Running RAM share association"
    else
      echo "[+] No new AWS accounts to process\n"
  fi

}

setup_ram_share_association() {

  if [[ "$application_name" != " " ]]; then

    echo "[+] processing ====> "${application_name}""

    #Runs a Terraform plan/apply in the member-vpc workspace to setup the RAM association
    for env in "${envs[@]}"; do

      #convert string to array
      IFS=' ' read -ra get_apps <<< "${application_name}"

      for new_app in "${get_apps[@]}"; do

        echo "[+] Running Terraform init"
        ./scripts/terraform-init.sh "$basedir/$new_app" 
        
        #Runs a Terraform plan/apply in the core-vpc-<env> to create the RAM share and association
        echo "[+] Selecting terraform application workspace ====> $new_app-$env"

        # Select workspace
        workspace=$(terraform -chdir="$basedir/$new_app" workspace select "$new_app-$env")
        
        if [[ "${workspace}" ]]; then

         echo "[+] Running Terraform plan"
        
         # Run terraform plan
         ./scripts/terraform-plan.sh "$basedir/$new_app"

         # Run terraform apply
         #./scripts/terraform-apply.sh "$basedir/$new_app"
        fi
      done
  done
  echo "[+] Finished running terraform across member accounts"
  else
      echo "[+] No RAM associations to process"
  fi
}


setup_ram_share_core
setup_ram_share_association

