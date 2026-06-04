from github_api import get_merged_pull_requests, make_github_api_call
from datetime import datetime, timedelta
import json
import os
import argparse
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
merged_pull_requests = []
per_page = 100

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

team_merged_pull_requests = 0
team_lead_time = timedelta()
date_query = args.date_query
date_range = date_query.split("..")
start_date = datetime.strptime(date_range[0], "%Y-%m-%d")
end_date = datetime.strptime(date_range[-1], "%Y-%m-%d")

# load the repository names from a JSON file
with open(args.filename, "r") as f:
    repos = json.load(f)["repos"]
for repo in repos:
    params = {
        "state": "closed",
        "sort": "updated",
        "direction": "desc",
        "per_page": per_page,
        "base": "main",
    }
    try:
        merged_pull_requests = get_merged_pull_requests(
            OWNER, repo, ACCESS_TOKEN, params
        )
    except Exception as e:
        # Log message if there's a problem retrieving pull requests
        print(f"Error retrieving pull requests: {e}")

    print(f"Found {len(merged_pull_requests)} merged pull requests.")

    # Calculate the mean lead time for 500 merged pull requests
    # Grabbing commits for all PRs takes too long. 500 is a reasonable compromise between execution time and accuracy

    total_lead_time = timedelta()
    num_pull_requests = 0
    # print(f'Number of Pull Requests: {num_pull_requests}')
    for pr in merged_pull_requests[0:500:1]:
        # Get the time the PR was merged
        merged_at = datetime.fromisoformat(pr["merged_at"][:-1])
        number = pr["number"]
        if start_date <= merged_at <= end_date:
            # print(f"PR {pr["number"]} is between {start_date} and {end_date} with {merged_at}")
            num_pull_requests += 1
            # Get the time of the last commit to the PR branch prior to the merge
            commits_url = pr["url"] + "/commits"
            try:
                commits = make_github_api_call(commits_url, ACCESS_TOKEN)
                # for commit in commits:
                #     commit_date = datetime.fromisoformat(commit["commit"]["committer"]["date"][:-1])
                #     print(f"Commit date: {commit_date}")
                if len(commits) > 0:
                    last_commit = commits[
                        -1
                    ]  # change to commits[0] to get first rather than commit.
                    commit_time = datetime.fromisoformat(
                        last_commit["commit"]["committer"]["date"][:-1]
                    )
                    # print(f"Commit date: {commit_time}")
                else:
                    commit_time = merged_at
            except Exception as e:
                # Log message if there's a problem retrieving commits
                print(f"Error retrieving commits: {e}")
                commit_time = merged_at
                break

            # Calculate the lead time for the pull request
            lead_time = merged_at - commit_time
            total_lead_time += lead_time
    team_lead_time += total_lead_time
    team_merged_pull_requests += num_pull_requests

if team_merged_pull_requests > 0:
    mean_lead_time = team_lead_time / team_merged_pull_requests
    message = (
        f"\033[32m\033[1mMean lead time for {filename} team over "
        f"{team_merged_pull_requests} merged pull requests: {mean_lead_time.days} days, "
        f"{mean_lead_time.seconds // 3600} hours, "
        f"{(mean_lead_time.seconds % 3600) // 60} minutes\033[0m"
    )
    print(message)
    message = (
        f"\nMean lead time for {filename} team over "
        f"{team_merged_pull_requests} merged pull requests: {mean_lead_time.days} days, "
        f"{mean_lead_time.seconds // 3600} hours, "
        f"{(mean_lead_time.seconds % 3600) // 60}"
    )
    logger.info(message)

else:
    print("No merged pull requests found.")
    logger.info("No merged pull requests found.")
