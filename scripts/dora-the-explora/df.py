from datetime import datetime, timedelta
import argparse
import json
import os
from github_api import get_workflow_runs
import logging

OWNER = "ministryofjustice"

logger = logging.getLogger('MetricLogger')
logger.setLevel(logging.INFO)

fh = logging.FileHandler('output.log')
fh.setLevel(logging.INFO)

# Create formatter and set it for both handlers
formatter = logging.Formatter('%(message)s')
fh.setFormatter(formatter)

# Add the handlers to the logger
logger.addHandler(fh)


# Initialize variables
runs = []
per_page = 100
date_format = "%Y-%m-%dT%H:%M:%SZ"

# Read ACCESS_TOKEN from environment
ACCESS_TOKEN = os.environ["ACCESS_TOKEN"]

# set up the command-line argument parser
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="path to the input JSON file")
parser.add_argument(
    "date_query", help="date range in the format 2023-04-01..2023-05-01"
)
args = parser.parse_args()

filename, file_extension = os.path.splitext(args.filename)

# load the repository names from a JSON file
with open(args.filename, "r") as f:
    data = json.load(f)
    repos = data['repos']
    excluded_workflows = data['excluded_workflows']

num_successful_runs = 0

for repo in repos:
    params = {
        "branch": "main",
        "status": "success",
        "per_page": per_page,
        "created": args.date_query,
    }
    try:
        runs += get_workflow_runs(OWNER, repo, ACCESS_TOKEN, params)
        # Count the number of successful runs
    except Exception as e:
        # Log message if there's a problem retrieving the workflow runs
        print(f"Error retrieving workflow runs: {e}")

# Calculate number of successful runs (minus the excluded workflows)
num_successful_runs += len(
    [run for run in runs if run["name"] not in excluded_workflows]
    )

# Compute the number of days between the earliest and latest successful runs
if num_successful_runs > 0:
    earliest_run_date = datetime.strptime(runs[-1]["created_at"], date_format)
    latest_run_date = datetime.strptime(runs[0]["created_at"], date_format)
    delta_days = (latest_run_date - earliest_run_date).days
else:
    delta_days = timedelta(0).days
# Calculate the daily deployment frequency
deployment_frequency = num_successful_runs / delta_days if delta_days > 0 else None

# Print the result

if deployment_frequency is not None:
    print(f"\033[1m\033[32mDaily deployment frequency for {filename}: {deployment_frequency:.2f} deployments/day\033[0m")
    logger.info(f"\nDaily deployment frequency for {filename}: {deployment_frequency:.2f} deployments/day")
else:
    print(f"\033[1m\033[32m{filename} does not use github actions for deployments\033[0m")
    logger.info(f"{filename} does not use github actions for deployments")
