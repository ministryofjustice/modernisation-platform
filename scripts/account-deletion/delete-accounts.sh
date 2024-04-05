#!/bin/bash


# Define script names
script1="./delete-tf-state.sh"
script2="./delete-tf-resources.sh"
log_file="execution_log.txt"


# Initialize or clear the log file at the start of the script
> "$log_file"


# Function to execute a script
execute_script() {
   local script_path="$1"
   echo "$(date "+%Y-%m-%d %H:%M:%S") - Executing $script_path..." | tee -a "$log_file"
   # Execute the script without redirecting stdout/stderr to allow for user interaction
   if "$script_path"; then
       echo "$(date "+%Y-%m-%d %H:%M:%S") - Success: $script_path completed successfully." | tee -a "$log_file"
       return 0
   else
       local status=$?
       echo "$(date "+%Y-%m-%d %H:%M:%S") - Error: $script_path failed with status $status." | tee -a "$log_file"
       return $status
   fi
}


# Ensure scripts are executable
chmod +x "$script1" "$script2"


# Execute scripts in sequence, checking for success after each
echo "$(date "+%Y-%m-%d %H:%M:%S") - Starting to execute scripts..." | tee -a "$log_file"


execute_script "$script1"
status=$?
if [ $status -ne 0 ]; then
   echo "$(date "+%Y-%m-%d %H:%M:%S") - Stopping execution due to failure." | tee -a "$log_file"
   exit $status
fi


execute_script "$script2"
status=$?
if [ $status -ne 0 ]; then
   echo "$(date "+%Y-%m-%d %H:%M:%S") - Stopping execution due to failure." | tee -a "$log_file"
   exit $status
fi


echo "$(date "+%Y-%m-%d %H:%M:%S") - All scripts executed successfully." | tee -a "$log_file"
