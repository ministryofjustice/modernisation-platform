import os
import json
import datetime
from urllib import request, parse, error

import boto3
from botocore.exceptions import ClientError

GITHUB_API_URL = os.environ.get("GITHUB_API_URL", "https://api.github.com")
OWNER = os.environ["GITHUB_OWNER"]
REPO = os.environ["GITHUB_REPO"]
LOOKBACK_HOURS = int(os.environ.get("LOOKBACK_HOURS", "6"))
WORKFLOW_RUN_LOG_GROUP = os.environ["WORKFLOW_RUN_LOG_GROUP"]

logs_client = boto3.client("logs")


def _isoformat_github(dt: datetime.datetime) -> str:
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=datetime.timezone.utc)
    return dt.astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _fetch_all_runs(owner: str, repo: str, lookback_hours: int):
    """
    Fetch workflow runs from GitHub Actions API.
    Returns ALL workflows created in the lookback window from the main branch.
    """
    all_runs = []
    page = 1
    max_pages = 10
    
    # Calculate lookback window
    now_utc = datetime.datetime.now(datetime.timezone.utc)
    search_start_dt = now_utc - datetime.timedelta(hours=lookback_hours)
    search_start_iso = _isoformat_github(search_start_dt)
    
    print(f"Searching for workflows created since {search_start_iso} (last {lookback_hours} hours)")
    
    while page <= max_pages:
        url = f"{GITHUB_API_URL}/repos/{owner}/{repo}/actions/runs"
        params = {
            "branch": "main",
            "created": f">={search_start_iso}",
            "per_page": "100",
            "page": str(page)
        }
        
        query_string = parse.urlencode(params)
        full_url = f"{url}?{query_string}"
        
        print(f"Fetching from GitHub API (page {page}): {full_url}")
        
        try:
            req = request.Request(full_url)
            req.add_header("Accept", "application/vnd.github+json")
            req.add_header("X-GitHub-Api-Version", "2022-11-28")
            
            github_token = os.environ.get("GITHUB_TOKEN")
            if github_token:
                req.add_header("Authorization", f"Bearer {github_token}")
            
            with request.urlopen(req, timeout=30) as response:
                data = json.loads(response.read().decode("utf-8"))
                runs = data.get("workflow_runs", [])
                
                if not runs:
                    print("No more runs returned from API")
                    break
                
                all_runs.extend(runs)
                
                for run in runs:
                    print(f"  Run {run.get('id')}: created={run.get('created_at')}, updated={run.get('updated_at')}, status={run.get('status')}, conclusion={run.get('conclusion')}")
                
                print(f"Page {page}: Found {len(runs)} runs")
                
                if len(runs) < 100:
                    print("Reached last page")
                    break
                
                page += 1
                
        except error.HTTPError as e:
            print(f"GitHub HTTP error: {e.code} - {e.reason}")
            try:
                print(f"Response: {e.read().decode('utf-8')}")
            except:
                pass
            break
        except error.URLError as e:
            print(f"GitHub URL error: {e.reason}")
            break
        except Exception as e:
            print(f"Unexpected error: {str(e)}")
            break
    
    print(f"Total runs found: {len(all_runs)}")
    return all_runs


def _write_runs_to_cw_logs(context, runs):
    """
    Writes one log event per workflow run into the dedicated log group.
    Logs are structured as JSON for automatic parsing in CloudWatch Logs Insights.
    """
    log_group_name = WORKFLOW_RUN_LOG_GROUP
    log_stream_name = context.aws_request_id

    # Create log stream if it doesn't exist yet
    try:
        logs_client.create_log_stream(
            logGroupName=log_group_name, logStreamName=log_stream_name
        )
    except ClientError as e:
        if e.response["Error"]["Code"] != "ResourceAlreadyExistsException":
            raise

    now_ms = int(datetime.datetime.now(datetime.timezone.utc).timestamp() * 1000)
    events = []

    for r in runs:
        log_event = {
            "type": "WORKFLOW_RUN",
            "repository": f"{OWNER}/{REPO}",
            "id": r.get("id"),
            "run_number": r.get("run_number"),
            "workflow_name": r.get("name"),
            "status": r.get("status"),
            "conclusion": r.get("conclusion"),
            "created_at": r.get("created_at"),
            "updated_at": r.get("updated_at"),
            "run_attempt": r.get("run_attempt"),
            "event": r.get("event"),
            "workflow_id": r.get("workflow_id"),
            "head_branch": r.get("head_branch"),
            "head_sha": r.get("head_sha"),
            "actor": (r.get("actor") or {}).get("login"),
            "triggering_actor": (r.get("triggering_actor") or {}).get("login")
            if r.get("triggering_actor")
            else None,
            "html_url": r.get("html_url"),
        }
        
        log_event = {k: v for k, v in log_event.items() if v is not None}
        
        events.append(
            {
                "timestamp": now_ms,
                "message": json.dumps(log_event),
            }
        )
        now_ms += 1

    logs_client.put_log_events(
        logGroupName=log_group_name,
        logStreamName=log_stream_name,
        logEvents=events,
    )


def lambda_handler(event, context):
    print(f"Polling repository {OWNER}/{REPO} for workflows in last {LOOKBACK_HOURS} hours")

    runs = _fetch_all_runs(OWNER, REPO, LOOKBACK_HOURS)

    # Only write to custom log if there are workflow runs
    if runs:
        _write_runs_to_cw_logs(context, runs)
        print(f"Wrote {len(runs)} workflow runs into {WORKFLOW_RUN_LOG_GROUP}")
    else:
        print(f"No workflow runs found in last {LOOKBACK_HOURS} hours - skipping custom log write")

    return {
        "lookback_hours": LOOKBACK_HOURS,
        "count": len(runs),
    }