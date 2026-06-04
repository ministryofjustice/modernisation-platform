import requests
from urllib.parse import urlparse, parse_qs


def get_workflow_runs(owner, repo, token, params):
    """Retrieves all workflow runs for a given repository using the provided query parameters."""

    # Set the necessary authentication headers using the personal access token (PAT)
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json",
    }

    # Define the API endpoint to retrieve the workflow runs for the given repository
    url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs"

    # Retrieve all workflow runs for the given repository using the updated query parameters
    workflow_runs = []
    try:
        while True:
            response = requests.get(url, headers=headers, params=params, timeout=30)
            response.raise_for_status()
            response_json = response.json()

            workflow_runs.extend(response_json["workflow_runs"])

            if "next" in response.links:
                next_link = response.links["next"]["url"]
                # Get the value of the `page` parameter from the `next` link, if it exists
                url_parts = urlparse(next_link)
                page = parse_qs(url_parts.query).get("page", None)
                if page is not None:
                    page = int(page[0])
                    # Update the `page` parameter in the `params` dictionary to retrieve the next page of results
                    params["page"] = page
                # remove the query string from the URL as we don't need to specify the completed_at parameter in subsequent requests
                url = next_link.split("?")[0]
            else:
                break

        return workflow_runs

    except requests.exceptions.RequestException as e:
        # Raise an error if there's a problem retrieving the workflow runs
        raise ValueError(f"Error retrieving workflow runs: {e}")


def get_merged_pull_requests(owner, repo, token, params):
    """Retrieves all merged pull requests for a given repository using the provided query parameters."""

    # Set the necessary authentication headers using the personal access token (PAT)
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json",
    }

    # Define the API endpoint to retrieve the merged pull requests for the given repository
    url = f"https://api.github.com/repos/{owner}/{repo}/pulls"

    # Retrieve all merged pull requests for the given repository using the updated query parameters
    merged_pull_requests = []
    try:
        while True:
            response = requests.get(url, headers=headers, params=params, timeout=30)
            response.raise_for_status()
            response_json = response.json()

            # Filter only the merged pull requests from the list of closed pull requests
            for pull_request in response_json:
                if pull_request["merged_at"] is not None:
                    merged_pull_requests.append(pull_request)

            if "next" in response.links:
                next_link = response.links["next"]["url"]
                # Get the value of the `page` parameter from the `next` link, if it exists
                url_parts = urlparse(next_link)
                page = parse_qs(url_parts.query).get("page", None)
                if page is not None:
                    page = int(page[0])
                    # Update the `page` parameter in the `params` dictionary to retrieve the next page of results
                    params["page"] = page
                # remove the query string from the URL as we don't need to specify the completed_at parameter in subsequent requests
                url = next_link.split("?")[0]
            else:
                break

        return merged_pull_requests

    except requests.exceptions.RequestException as e:
        # Raise an error if there's a problem retrieving the pull requests
        raise ValueError(f"Error retrieving pull requests: {e}")


def make_github_api_call(url, token):
    # Set the necessary authentication headers using the personal access token (PAT)
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json",
    }
    try:
        response = requests.get(url, headers=headers)
        commits = response.json()
        return commits
    except requests.exceptions.RequestException as e:
        # Raise an error if there's a problem retrieving the pull requests
        raise ValueError(f"Error retrieving pull requests: {e}")
