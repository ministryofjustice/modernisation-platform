from flask import Flask, redirect, request
import os

import requests


app = Flask(__name__)


def dispatch_to_github(payload: dict) -> None:
    token = os.environ.get("GH_DISPATCH_TOKEN", "")
    owner = os.environ.get("GH_OWNER", "ministryofjustice")
    repo = os.environ.get("GH_REPO", "modernisation-platform")

    if not token:
        raise RuntimeError("Missing GH_DISPATCH_TOKEN")

    url = f"https://api.github.com/repos/{owner}/{repo}/dispatches"
    body = {
        "event_type": "collaborator_pr_decision",
        "client_payload": payload,
    }

    response = requests.post(
        url,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "Content-Type": "application/json",
            "User-Agent": "mp-collaborator-pr-decision-service",
        },
        json=body,
        timeout=15,
    )
    response.raise_for_status()


@app.get("/healthz")
def healthz():
    return {"status": "ok"}, 200


@app.get("/decision")
def decision():
    action = (request.args.get("action") or "").strip().lower()
    pr_number = (request.args.get("pr_number") or "").strip()
    issue_number = (request.args.get("issue_number") or "").strip()
    timestamp = (request.args.get("ts") or "").strip()
    signature = (request.args.get("sig") or "").strip()

    if action not in {"approve", "reject"}:
        return "Invalid action", 400

    if not all([pr_number, issue_number, timestamp, signature]):
        return "Missing required query parameters", 400

    payload = {
        "action": action,
        "pr_number": pr_number,
        "issue_number": issue_number,
        "timestamp": timestamp,
        "signature": signature,
    }

    try:
        dispatch_to_github(payload)
    except requests.HTTPError as exc:
        return f"GitHub dispatch failed: {exc}", 502
    except Exception as exc:
        return f"Unexpected error: {exc}", 500

    target_owner = os.environ.get("TARGET_OWNER", "ministryofjustice")
    target_repo = os.environ.get("TARGET_REPO", "modernisation-platform-github")
    redirect_url = f"https://github.com/{target_owner}/{target_repo}/pull/{pr_number}"
    return redirect(redirect_url, code=302)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
