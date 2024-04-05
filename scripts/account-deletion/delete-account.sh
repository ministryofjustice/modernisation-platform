#!/bin/bash


# Define script names
script1="./terraform_deploy.sh"
script2="./terraform_destroy.sh"
log_file="execution_log.txt"


# Initialize or clear the log file at the start of the script
> "$log_file"


# Function to execute a script with retry and exponential backoff
execute_script_with_retry() {
   local script_path="$1"
   local max_attempts=5
   local attempt=0
   local sleep_seconds=2


   while [ $attempt -lt $max_attempts ]; do
       echo "$(date "+%Y-%m-%d %H:%M:%S") - Attempt $((attempt + 1)) of $max_attempts: Executing $script_path..." | tee -a "$log_file"
       # Execute the script without redirecting stdout/stderr to allow for user interaction
       if "$script_path"; then
           echo "$(date "+%Y-%m-%d %H:%M:%S") - Success: $script_path completed successfully." | tee -a "$log_file"
           return 0
       else
           status=$?
           echo "$(date "+%Y-%m-%d %H:%M:%S") - Warning: $script_path failed with status $status. Retrying in $sleep_seconds seconds..." | tee -a "$log_file"
           # Sleep and double the backoff time for the next retry
           sleep $sleep_seconds
           sleep_seconds=$((sleep_seconds * 2))
       fi
       attempt=$((attempt + 1))
   done


   echo "$(date "+%Y-%m-%d %H:%M:%S") - Error: $script_path failed after $max_attempts attempts." | tee -a "$log_file"
   return $status
}


# Ensure scripts are executable
chmod +x "$script1" "$script2"


# Execute scripts in sequence, checking for success after each with retry logic
echo "$(date "+%Y-%m-%d %H:%M:%S") - Starting to execute scripts with retry logic..." | tee -a "$log_file"


execute_script_with_retry "$script1"
status=$?
if [ $status -ne 0 ]; then
   echo "$(date "+%Y-%m-%d %H:%M:%S") - Stopping execution due to failure." | tee -a "$log_file"
   exit $status
fi


execute_script_with_retry "$script2"
status=$?
if [ $status -ne 0 ]; then
   echo "$(date "+%Y-%m-%d %H:%M:%S") - Stopping execution due to failure." | tee -a "$log_file"
   exit $status
fi


echo "$(date "+%Y-%m-%d %H:%M:%S") - All scripts executed successfully." | tee -a "$log_file"
