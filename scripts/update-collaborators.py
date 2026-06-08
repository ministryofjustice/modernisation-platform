#!/usr/bin/env python3

import argparse
import json
from pathlib import Path


def parse_environments(raw_value: str) -> list[str]:
    value = (raw_value or "").strip()
    if not value:
        return []

    cleaned = (
        value.replace("\r", "\n")
        .replace(",", "\n")
        .replace("- ", "")
        .replace("* ", "")
    )
    parts = [p.strip() for p in cleaned.split("\n") if p.strip()]

    seen = set()
    result = []
    for part in parts:
        normalized = part.lower()
        if normalized not in seen:
            seen.add(normalized)
            result.append(normalized)
    return result


def upsert_collaborator(
    collaborators_path: Path,
    username: str,
    github_username: str,
    application: str,
    environments: list[str],
    access: str,
) -> dict:
    with collaborators_path.open("r", encoding="utf-8") as file:
        data = json.load(file)

    users = data.setdefault("users", [])
    user = next((u for u in users if u.get("username") == username), None)

    if user is None:
        user = {
            "username": username,
            "github-username": github_username,
            "accounts": [],
        }
        users.append(user)
    else:
        user["github-username"] = github_username
        user.setdefault("accounts", [])

    existing_pairs = {
        (acc.get("account-name"), acc.get("access")) for acc in user["accounts"]
    }

    added_count = 0
    for environment in environments:
        account_name = f"{application}-{environment}"
        pair = (account_name, access)
        if pair in existing_pairs:
            continue
        user["accounts"].append({"account-name": account_name, "access": access})
        existing_pairs.add(pair)
        added_count += 1

    with collaborators_path.open("w", encoding="utf-8") as file:
        json.dump(data, file, indent=2)
        file.write("\n")

    return {
        "username": username,
        "github_username": github_username,
        "application": application,
        "environments": environments,
        "access": access,
        "added_accounts": added_count,
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Insert or update a collaborator in collaborators.json"
    )
    parser.add_argument("--file", required=True, help="Path to collaborators.json")
    parser.add_argument("--username", required=True, help="Collaborator username")
    parser.add_argument(
        "--github-username",
        required=True,
        help="Collaborator GitHub username",
    )
    parser.add_argument(
        "--application",
        required=True,
        help="Application name used as account-name prefix",
    )
    parser.add_argument(
        "--environments",
        required=True,
        help="Environment list (comma or newline separated)",
    )
    parser.add_argument(
        "--access",
        default="developer",
        help="Access level to assign for each environment (default: developer)",
    )

    args = parser.parse_args()

    collaborators_path = Path(args.file)
    if not collaborators_path.exists():
        raise FileNotFoundError(f"File not found: {collaborators_path}")

    environments = parse_environments(args.environments)
    if not environments:
        raise ValueError("No environments were provided")

    result = upsert_collaborator(
        collaborators_path=collaborators_path,
        username=args.username.strip(),
        github_username=args.github_username.strip(),
        application=args.application.strip(),
        environments=environments,
        access=args.access.strip(),
    )

    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())