from datetime import datetime, timedelta
from github_api import get_workflow_runs
import json
import argparse
import os
from collections import defaultdict
import logging

# replace with your personal access token and repo information

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


workflow_periods = defaultdict(list)
workflow_stacks = defaultdict(list)

# Read ACCESS_TOKEN from environment
ACCESS_TOKEN = os.environ["ACCESS_TOKEN"]

# set up the command-line argument parser
parser = argparse.ArgumentParser()
parser.add_argument("filename", help="path to the input JSON file")
parser.add_argument(
    "date_query", help="date range in the format 2023-04-01..2023-05-01"
)
args = parser.parse_args()


# Initialize variables
runs = []
per_page = 100

# load the repository names from a JSON file
with open(args.filename, "r") as f:
    data = json.load(f)
    repos = data['repos']
    excluded_workflows = data['excluded_workflows']

filename, file_extension = os.path.splitext(args.filename)


# loop over each repository
for repo in repos:
    # Get all workflow runs on the main branch
    params = {"branch": "main", "per_page": per_page, "created": args.date_query}
    try:
        repo_run = get_workflow_runs(OWNER, repo, ACCESS_TOKEN, params)
        print(f"Retrieved {len(repo_run)} workflow runs for {OWNER}/{repo}")
        runs += repo_run

    except Exception as e:
        # Log message if there's a problem retrieving the workflow runs
        print(f"Error retrieving workflow runs: {e}")

print(f"Retrieved {len(runs)} workflow runs in total")

# sort the workflow runs by created_at in ascending order
runs = sorted(
    runs, key=lambda run: datetime.fromisoformat(run["created_at"].replace("Z", ""))
)
# filter the unsuccessful runs
unsuccessful_runs = [run for run in runs if run["conclusion"] != "success"]

# find the periods between the first unsuccessful run and the first subsequent successful run for each workflow
for run in runs:
    workflow_id = run["workflow_id"]
    workflow_name = run["name"]

    if workflow_name in excluded_workflows:
        continue

    timestamp = datetime.fromisoformat(run["created_at"].replace("Z", ""))

    if run["conclusion"] != "success":
        if not workflow_stacks[workflow_id]:
            workflow_stacks[workflow_id].append(timestamp)
            print(f"Found new failure for workflow '{workflow_name}' at {timestamp}")
    else:
        if workflow_stacks[workflow_id]:
            start = workflow_stacks[workflow_id].pop()
            period = {"start": start, "end": timestamp}
            workflow_periods[workflow_id].append(period)
            print(f"Found new success for workflow '{workflow_name}' at {timestamp}")
        workflow_stacks[workflow_id] = []
# calculate the time to recovery for each workflow
workflow_recovery_times = {
    workflow_id: [
        period["end"] - period["start"] for period in periods if period["end"]
    ]
    for workflow_id, periods in workflow_periods.items()
}

# print("### Workflow Recovery Dict ###")
# pprint.pprint(workflow_recovery_times)

total_workflows = sum(len(periods) for periods in workflow_periods.values())
print(f"Total Workflows: {total_workflows}")
total_recovery_time = sum(
    (
        time_to_recovery
        for workflow_times in workflow_recovery_times.values()
        for time_to_recovery in workflow_times
    ),
    timedelta(0),
)
mean_time_to_recovery = (
    total_recovery_time / total_workflows if total_workflows > 0 else None
)

if mean_time_to_recovery is not None:
    days, seconds = mean_time_to_recovery.days, mean_time_to_recovery.seconds
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    print(f"\033[32m\033[1mMean time to recovery for {filename}: {days} days, {hours} hours, {minutes} minutes\033[0m")
    logger.info(f"\nMean time to recovery for {filename}: {days} days, {hours} hours, {minutes} minutes")
else:
    print("No unsuccessful workflow runs found in the last 90 days.")
    logger.info("No unsuccessful workflow runs found in the last 90 days.")
