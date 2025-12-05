#!/usr/bin/env python3
import argparse, json, os, sys
from typing import Any, Dict, List

def load_json(path: str) -> Dict[str, Any]:
    if not os.path.exists(path):
        return {}
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
    raw = raw.strip()
    if not raw:
        return None
    try:
        return json.loads(raw)
    except Exception as e:
        print(f"ERROR: invalid JSON payload: {e}", file=sys.stderr)
        sys.exit(1)

def parse_keys(raw: str) -> List[str]:
    if not raw.strip():
        return []
    return [k.strip() for k in raw.split(",") if k.strip()]

def apply_environment_change(root: Dict[str, Any], change_type: str, name: str, payload: Any):
    if change_type == "none":
        return
    if change_type == "removal":
        envs = root.get("environments")
        if isinstance(envs, list):
            before = len(envs)
            root["environments"] = [e for e in envs if e.get("name") != name]
            print(f"Removed environment '{name}' (delta {before - len(root['environments'])})")
        return
    if change_type in ("addition", "update"):
        if not name:
            print("ERROR: environment-name required", file=sys.stderr); sys.exit(1)
        if payload is None or not isinstance(payload, dict):
            print("ERROR: environment-payload must be object", file=sys.stderr); sys.exit(1)
        env_list = root.setdefault("environments", [])
        existing = next((e for e in env_list if e.get("name") == name), None)
        payload.setdefault("name", name)
        if existing is None:
            env_list.append(payload)
            print(f"Added environment '{name}'")
        else:
            deep_merge(existing, payload)
            existing["name"] = name
            print(f"Updated environment '{name}'")

def apply_tags_change(root: Dict[str, Any], change_type: str, payload: Any, remove_keys: List[str]):
    if change_type == "none":
        return
    if change_type == "removal":
        tags = root.get("tags")
        if isinstance(tags, dict):
            for k in remove_keys:
                tags.pop(k, None)
            print(f"Removed tag keys: {', '.join(remove_keys) or '(none)'}")
        return
    if change_type in ("addition", "update"):
        if payload is None or not isinstance(payload, dict):
            print("ERROR: tags-payload must be object", file=sys.stderr); sys.exit(1)
        tags = root.setdefault("tags", {})
        deep_merge(tags, payload)
        print(f"Merged tags: {', '.join(payload.keys())}")

def apply_other_change(root: Dict[str, Any], change_type: str, payload: Any, remove_keys: List[str]):
    if change_type == "none":
        return
    reserved = {"environments", "tags"}
    if change_type == "removal":
        for k in remove_keys:
            if k in reserved:
                print(f"ERROR: cannot remove reserved key '{k}'", file=sys.stderr); sys.exit(1)
            root.pop(k, None)
        print(f"Removed other keys: {', '.join(remove_keys) or '(none)'}")
        return
    if change_type in ("addition", "update"):
        if payload is None or not isinstance(payload, dict):
            print("ERROR: other-payload must be object", file=sys.stderr); sys.exit(1)
        for k in payload:
            if k in reserved:
                print(f"ERROR: other-payload cannot include reserved key '{k}'", file=sys.stderr); sys.exit(1)
        deep_merge(root, payload)
        print(f"Merged other keys: {', '.join(payload.keys())}")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--account-name", required=False, default="")
    p.add_argument("--target-file", required=True)
    p.add_argument("--environments-change-type", required=True, choices=["none","addition","update","removal"])
    p.add_argument("--environment-name", default="")
    p.add_argument("--environment-payload", default="")
    p.add_argument("--tags-change-type", required=True, choices=["none","addition","update","removal"])
    p.add_argument("--tags-payload", default="")
    p.add_argument("--tags-remove-keys", default="")
    p.add_argument("--other-change-type", required=True, choices=["none","addition","update","removal"])
    p.add_argument("--other-payload", default="")
    p.add_argument("--other-remove-keys", default="")
    args = p.parse_args()

    # Safety check that target_file matches account-name expectation
    if args.account_name:
        expected = f"environments/{args.account_name.lower()}.json"
        if os.path.normpath(args.target_file) != os.path.normpath(expected):
            print(f"NOTE: target-file '{args.target_file}' differs from account '{args.account_name}' (expected '{expected}')", file=sys.stderr)

    data = load_json(args.target_file)

    env_payload = parse_json_or_none(args.environment_payload)
    tags_payload = parse_json_or_none(args.tags_payload)
    other_payload = parse_json_or_none(args.other_payload)
    tags_remove = parse_keys(args.tags_remove_keys)
    other_remove = parse_keys(args.other_remove_keys)

    apply_environment_change(data, args.environments_change_type, args.environment_name, env_payload)
    apply_tags_change(data, args.tags_change_type, tags_payload, tags_remove)
    apply_other_change(data, args.other_change_type, other_payload, other_remove)

    save_json(args.target_file, data)
    print(f"Updated file: {args.target_file}")

if __name__ == "__main__":
    main()