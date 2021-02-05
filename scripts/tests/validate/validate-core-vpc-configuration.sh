#!/usr/bin/env bash

git_dir="$( git rev-parse --show-toplevel )"

#Set error flag
error_flag=0

#Load validation values into variables
test_data=`cat ${git_dir}/scripts/tests/validate/fixtures/pre-terraform-core-vpc-validation.json`

#Load list of business-units
business_units=`jq -rn --argjson DATA "${test_data}" '$DATA.protected | keys | .[]'`

for file in ${business_units}
  do
  #Set specific account_environment file_flag
  account_environment_flag=0

  #Load real data for business unit and environment into a variable
  filename="${git_dir}/environments-networks/${file}.json"
 
  if [ -f ${filename} ]
    then
    real_data=`cat "${filename}"`
  else
    echo "ERROR: Issue opening configuration file - ${filename}"
    error_flag=1
    account_environment_flag=1
  fi
   
  if [ "${account_environment_flag}" = 0 ]
    then
    for check_type in "transit_gateway" "protected" "subnet_sets"
      do
      #Check $check_type match the test critera
      real_json=`jq -nr --arg CHECK_TYPE "${check_type}" --argjson REAL "${real_data}" '$REAL.cidr[$CHECK_TYPE]'`
      test_json=`jq -nr --arg CHECK_TYPE "${check_type}" --arg DEPARTMENT_ENV "${file}" --argjson TEST "${test_data}" '$TEST[$CHECK_TYPE][$DEPARTMENT_ENV]'`
      if [ "${test_json}" != "${real_json}" ] 
        then
        echo "ERROR: Core-VPC configuration, ${file} ${check_type} does not match tested values"
        error_flag=1
      fi
    done
fi
done

#Check error_flag
if [ "${error_flag}" = 0 ]
  then
  echo "All tests passed"
  exit 0
else
  echo "TESTS FAILED - please correct the listed issues"
  exit 1
fi