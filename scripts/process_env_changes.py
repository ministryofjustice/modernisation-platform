#!/usr/bin/env python3
import argparse, json, os, sys, re
from typing import Any, Dict, List, Optional


def load_json(path: str) -> Dict[str, Any]:
    if not os.path.exists(path):
        print(f"ERROR: target file not found: {path}", file=sys.stderr)
        sys.exit(1)
    with open(path) as f:
        return json.load(f)


def save_json(path: str, data: Dict[str, Any]) -> None:
    with open(path, "w") as f:
        json.dump(data, f, indent=2, sort_keys=False)
        f.write("\n")


def deep_merge(dst, src):
    if isinstance(dst, dict) and isinstance(src, dict):
        for k, v in src.items():
            dst[k] = deep_merge(dst.get(k), v) if k in dst else v
        return dst
    return src


def parse_json_or_none(raw: str):
    raw = (raw or "").strip()
    if not raw:
        return None
    try:
        return json.loads(raw)
    except Exception as e:
        print(f"ERROR: invalid JSON payload: {e}", file=sys.stderr)
        sys.exit(1)


def parse_keys(raw: str) -> List[str]:
    raw = (raw or "").strip()
    if not raw:
        return []
    return [k.strip() for k in raw.split(",") if k.strip()]

def parse_list(raw: str) -> List[str]:
    return parse_keys(raw)

def validate_date_ddmmyyyy(raw: str) -> Optional[str]:
    raw = (raw or "").strip()
    if not raw:
        return None
    if not re.match(r"^\d{2}-\d{2}-\d{4}$", raw):
        print("ERROR: go-live date must be DD-MM-YYYY", file=sys.stderr)
        sys.exit(1)
    return raw


def get_environment(root: Dict[str, Any], env_name: str) -> Dict[str, Any]:
    envs = root.setdefault("environments", [])
    if not isinstance(envs, list):
        print("ERROR: 'environments' must be a list", file=sys.stderr)
        sys.exit(1)
    existing = next((e for e in envs if e.get("name") == env_name), None)
    if existing is None:
        existing = {"name": env_name}
        envs.append(existing)
    return existing

def apply_environment_access_change(
    root: Dict[str, Any],
    action: str,
    env_name: str,
    current_group: str,
    current_level: str,
    new_group: str,
    new_level: str,
):
    if action == "skip":
        return
    if not env_name:
        print("ERROR: environment-name is required", file=sys.stderr)
        sys.exit(1)
    env = get_environment(root, env_name)
    access = env.setdefault("access", [])
    if not isinstance(access, list):
        print("ERROR: environment.access must be a list", file=sys.stderr)
        sys.exit(1)

    def match(entry: Dict[str, Any], grp: str, lvl: str) -> bool:
        return entry.get("sso_group_name") == grp and entry.get("level") == lvl

    if action == "amend":
        if not current_group or not current_level:
            print("ERROR: current_sso_group_name and current_level required for amend", file=sys.stderr)
            sys.exit(1)
        if not new_group and not new_level:
            print("ERROR: provide at least one of sso_group_name or level for amend", file=sys.stderr)
            sys.exit(1)
        target = next((e for e in access if match(e, current_group, current_level)), None)
        if target is None:
            print("ERROR: existing access entry not found for provided current values", file=sys.stderr)
            sys.exit(1)
        if new_group:
            target["sso_group_name"] = new_group
        if new_level:
            target["level"] = new_level
        print(f"Amended access in '{env_name}'")
        return

    if action == "addition":
        if not new_group or not new_level:
            print("ERROR: sso_group_name and level required for addition", file=sys.stderr)
            sys.exit(1)
        access.append({"sso_group_name": new_group, "level": new_level})
        print(f"Added access in '{env_name}'")
        return

    print("ERROR: unknown environment change action", file=sys.stderr)
    sys.exit(1)


def apply_tags_change(root: Dict[str, Any], action: str, current_key: str, current_value: str, new_key: str, new_value: str):
    if action == "skip":
        return
    tags = root.setdefault("tags", {})
    if not isinstance(tags, dict):
        print("ERROR: tags must be an object", file=sys.stderr)
        sys.exit(1)
    if action == "amend":
        if not current_key:
            print("ERROR: current_tag_key required for amend", file=sys.stderr)
            sys.exit(1)
        if current_key not in tags:
            print("ERROR: current tag key not found", file=sys.stderr)
            sys.exit(1)
        # If provided, verify current value matches
        if current_value and str(tags.get(current_key)) != current_value:
            print("ERROR: current tag value does not match", file=sys.stderr)
            sys.exit(1)
        if not new_key:
            # keep same key, update value
            if new_value is None or new_value == "":
                print("ERROR: tag value required for amend", file=sys.stderr)
                sys.exit(1)
            tags[current_key] = new_value
        else:
            # rename key if new_key provided
            if new_value is None or new_value == "":
                print("ERROR: tag value required for amend", file=sys.stderr)
                sys.exit(1)
            tags.pop(current_key, None)
            tags[new_key] = new_value
        print("Amended tag")
        return
    if action == "addition":
        if not new_key:
            print("ERROR: tag_key required for addition", file=sys.stderr)
            sys.exit(1)
        if new_value is None or new_value == "":
            print("ERROR: tag_value required for addition", file=sys.stderr)
            sys.exit(1)
        tags[new_key] = new_value
        print("Added/updated tag")
        return
    print("ERROR: unknown tags change action", file=sys.stderr)
    sys.exit(1)


def apply_other_change(
    root: Dict[str, Any],
    action: str,
    current_repos: List[str],
    current_date: Optional[str],
    new_repos: List[str],
    new_date: Optional[str],
):
    if action == "skip":
        return
    # Reserved keys are implicitly protected by only touching known keys
    if action == "amend":
        # github-oidc-team-repositories
        if current_repos:
            existing = root.get("github-oidc-team-repositories")
            if not isinstance(existing, list):
                existing = []
            # Not strict equality check; ensure current are subset
            for r in current_repos:
                if r not in existing:
                    print("ERROR: current github-oidc-team-repositories do not match", file=sys.stderr)
                    sys.exit(1)
        if new_repos:
            root["github-oidc-team-repositories"] = new_repos
        # go-live-date
        if current_date:
            existing_date = root.get("go-live-date")
            if existing_date != current_date:
                print("ERROR: current go-live-date does not match", file=sys.stderr)
                sys.exit(1)
        if new_date is not None:
            root["go-live-date"] = new_date
        print("Amended other fields")
        return
    if action == "addition":
        if new_repos:
            root["github-oidc-team-repositories"] = new_repos
        if new_date is not None:
            root["go-live-date"] = new_date
        print("Set other fields")
        return
    print("ERROR: unknown other change action", file=sys.stderr)
    sys.exit(1)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--account-name", required=True)
    # Environment access
    p.add_argument("--environment-change-action", required=True, choices=["skip","amend","addition"])
    p.add_argument("--environment-name", default="")
    p.add_argument("--current-sso-group-name", default="")
    p.add_argument("--current-level", default="")
    p.add_argument("--sso-group-name", default="")
    p.add_argument("--level", default="")
    # Reviewers
    p.add_argument("--reviewers-change-action", required=True, choices=["skip","amend","addition"])
    p.add_argument("--current-additional-reviewers", default="")
    p.add_argument("--additional-reviewers", default="")
    # Tags
    p.add_argument("--tags-change-action", required=True, choices=["skip","amend","addition"])
    p.add_argument("--current-tag-key", default="")
    p.add_argument("--current-tag-value", default="")
    p.add_argument("--tag-key", default="")
    p.add_argument("--tag-value", default="")
    # Other
    p.add_argument("--other-change-action", required=True, choices=["skip","amend","addition"])
    p.add_argument("--current-github-oidc-team-repositories", default="")
    p.add_argument("--current-go-live-date", default="")
    p.add_argument("--github-oidc-team-repositories", default="")
    p.add_argument("--go-live-date", default="")
    args = p.parse_args()

    # Derive target path from account name
    target_file = f"environments/{args.account_name.lower()}.json"
    data = load_json(target_file)

    # Environment access changes
    apply_environment_access_change(
        data,
        args.environment_change_action,
        args.environment_name,
        args.current_sso_group_name,
        args.current_level,
        args.sso_group_name,
        args.level,
    )

    # Reviewers changes (per environment key: 'additional_reviewers')
    reviewers_action = args.reviewers_change_action
    current_reviewers = parse_list(args.current_additional_reviewers)
    new_reviewers = parse_list(args.additional_reviewers)
    if reviewers_action != "skip":
        if not args.environment_name:
            print("ERROR: environment-name is required for reviewers changes", file=sys.stderr)
            sys.exit(1)
        env = get_environment(data, args.environment_name)
        existing = env.get("additional_reviewers")
        if not isinstance(existing, list):
            existing = []
        if reviewers_action == "amend":
            if not current_reviewers:
                print("ERROR: current_additional_reviewers required for amend", file=sys.stderr)
                sys.exit(1)
            # Ensure all current reviewers exist
            for r in current_reviewers:
                if r not in existing:
                    print("ERROR: current reviewers do not match existing", file=sys.stderr)
                    sys.exit(1)
            # Replace with new list (can be empty to clear)
            env["additional_reviewers"] = new_reviewers
            print(f"Amended additional reviewers in '{args.environment_name}'")
        elif reviewers_action == "addition":
            if not new_reviewers:
                print("ERROR: additional_reviewers required for addition", file=sys.stderr)
                sys.exit(1)
            lst = list(existing)
            for r in new_reviewers:
                if r not in lst:
                    lst.append(r)
            env["additional_reviewers"] = lst
            print(f"Appended additional reviewers in '{args.environment_name}'")
        else:
            print("ERROR: unknown reviewers change action", file=sys.stderr)
            sys.exit(1)

    # Tags changes
    apply_tags_change(
        data,
        args.tags_change_action,
        args.current_tag_key,
        args.current_tag_value,
        args.tag_key,
        args.tag_value,
    )

    # Other changes
    current_repos = parse_list(args.current_github_oidc_team_repositories)
    new_repos = parse_list(args.github_oidc_team_repositories)
    current_date = validate_date_ddmmyyyy(args.current_go_live_date)
    new_date = validate_date_ddmmyyyy(args.go_live_date)
    apply_other_change(
        data,
        args.other_change_action,
        current_repos,
        current_date,
        new_repos,
        new_date,
    )

    save_json(target_file, data)
    print(f"Updated file: {target_file}")


if __name__ == "__main__":
    main()
