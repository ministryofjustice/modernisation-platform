# pyright: reportMissingImports=false

import json
import os
import urllib.error
import urllib.parse
import urllib.request


def _response(status_code, body, headers=None):
    return {
        "statusCode": status_code,
        "headers": headers or {"Content-Type": "text/plain"},
        "body": body,
    }


def _get_query_params(event):
    params = event.get("queryStringParameters") or {}
    return {
        "action": (params.get("action") or "").strip().lower(),
        "pr_number": (params.get("pr_number") or "").strip(),
        "issue_number": (params.get("issue_number") or "").strip(),
        "timestamp": (params.get("ts") or "").strip(),
        "signature": (params.get("sig") or "").strip(),
    }


def _dispatch_to_github(payload):
    token = _get_dispatch_token()
    owner = os.environ.get("GH_OWNER", "ministryofjustice")
    repo = os.environ.get("GH_REPO", "modernisation-platform")

    if not token:
        raise RuntimeError("Missing GH_DISPATCH_TOKEN")

    url = f"https://api.github.com/repos/{owner}/{repo}/dispatches"
    request_body = json.dumps(
        {
            "event_type": "collaborator_pr_decision",
            "client_payload": payload,
        }
    ).encode("utf-8")

    req = urllib.request.Request(
        url,
        data=request_body,
        method="POST",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "Content-Type": "application/json",
            "User-Agent": "mp-collaborator-pr-decision-lambda",
        },
    )

    with urllib.request.urlopen(req, timeout=15) as resp:
        return resp.status


def _get_dispatch_token():
    import boto3

    token = os.environ.get("GH_DISPATCH_TOKEN", "")
    if token:
        return token

    secret_name = os.environ.get("GH_DISPATCH_TOKEN_SECRET_NAME", "")
    if not secret_name:
        return ""

    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId=secret_name)
    secret_string = response.get("SecretString", "")
    if not secret_string:
        return ""

    # Accept either plain string secret values or JSON payloads.
    try:
        parsed = json.loads(secret_string)
    except json.JSONDecodeError:
        return secret_string.strip()

    if isinstance(parsed, str):
        return parsed.strip()

    return str(parsed.get("token") or parsed.get("dispatch_token") or "").strip()


def lambda_handler(event, context):
    del context

    params = _get_query_params(event)

    if params["action"] not in {"approve", "reject"}:
        return _response(400, "Invalid action")

    missing = [k for k, v in params.items() if not v]
    if missing:
        return _response(400, f"Missing required parameters: {', '.join(missing)}")

    payload = {
        "action": params["action"],
        "pr_number": params["pr_number"],
        "issue_number": params["issue_number"],
        "timestamp": params["timestamp"],
        "signature": params["signature"],
    }

    try:
        _dispatch_to_github(payload)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        return _response(502, f"GitHub dispatch failed: {exc.code} {detail}")
    except Exception as exc:  # noqa: BLE001
        return _response(500, f"Unexpected error: {exc}")

    target_owner = os.environ.get("TARGET_OWNER", "ministryofjustice")
    target_repo = os.environ.get("TARGET_REPO", "modernisation-platform-github")
    redirect_url = f"https://github.com/{target_owner}/{target_repo}/pull/{params['pr_number']}"

    return _response(
        302,
        "Decision received. Redirecting...",
        headers={"Location": redirect_url},
    )
