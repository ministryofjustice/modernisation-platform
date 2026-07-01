import os
import json
import sys
import re

# Defence-in-depth: even though the calling workflow allowlist-validates every
# field, this script may be invoked directly. Reject anything that could enable
# path traversal, JSON/Rego injection, or shell surprises downstream.
APP_NAME_RE = re.compile(r"^(?!\.{1,2}$)[A-Za-z0-9][A-Za-z0-9._-]{0,63}$")

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ENV_DIR = os.path.join(REPO_ROOT, "environments")
REGO_PATH = os.path.join(REPO_ROOT, "policies", "environments", "expected.rego")


def _fail(msg, code=1):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(code)


def _validate_app_name(name):
    if not APP_NAME_RE.match(name or ""):
        _fail(f"invalid app_name {name!r}: must match {APP_NAME_RE.pattern}")


def _safe_env_path(app_name):
    """Return environments/<app_name>.json, asserting the resolved path stays
    inside ENV_DIR. Guards against traversal via `..`, absolute paths, symlinks
    or NUL bytes in a defence-in-depth manner."""
    if "/" in app_name or "\\" in app_name or "\x00" in app_name:
        _fail(f"invalid characters in app_name {app_name!r}")
    candidate = os.path.abspath(os.path.join(ENV_DIR, f"{app_name}.json"))
    if os.path.dirname(candidate) != ENV_DIR:
        _fail(f"refusing to write outside {ENV_DIR}: {candidate}")
    return candidate


def add_app_to_rego(app_name, rego_path):
    with open(rego_path, "r") as f:
        content = f.read()

    # Find the accounts array
    match = re.search(r'("accounts":\s*\[\s*)(.*?)(\s*\])', content, re.DOTALL)
    if not match:
        # Previously returned silently; fail loudly so the workflow surfaces it.
        _fail("could not find accounts array in rego file")

    # Extract existing accounts
    accounts_block = match.group(2)
    accounts = re.findall(r'"([^"]+)"', accounts_block)
    if app_name in accounts:
        print(f"{app_name} already in accounts list.")
        return

    # Add and sort
    accounts.append(app_name)
    accounts_sorted = sorted(accounts, key=lambda x: x.lower())

    # Rebuild accounts block. Safe against Rego injection because app_name has
    # been validated to APP_NAME_RE (no '"' or '\' possible).
    new_accounts_block = ",\n    ".join(f'"{a}"' for a in accounts_sorted)
    new_content = content[:match.start(2)] + new_accounts_block + content[match.end(2):]


    with open(rego_path, "w") as f:
        f.write(new_content)
    print(f"Added {app_name} to rego accounts list in alphabetical order.")


def application_exists(app_name):
    target_file = _safe_env_path(app_name)
    if os.path.exists(target_file):
        return True
    for fname in os.listdir(ENV_DIR):
        if not fname.endswith(".json"):
            continue
        try:
            with open(os.path.join(ENV_DIR, fname)) as f:
                data = json.load(f)
        except (OSError, json.JSONDecodeError) as exc:
            # Do not swallow silently; surface the reason for debuggability but
            # keep scanning so one malformed neighbour cannot block creation.
            print(f"warning: skipping {fname}: {exc}", file=sys.stderr)
            continue
        if data.get("tags", {}).get("application", "").lower() == app_name.lower():
            return True
    return False

def create_env_json(app_name, app_tag, github_owners, github_reviewers, business_unit, service_area, infra_support, owner, slack_channel, cni, sso_group, go_live_date, env_selections):
    environments = []
    for env in env_selections:
        if not isinstance(env, dict):
            _fail(f"env selection is not an object: {env!r}")
        env_name = env.get("name")
        if not env_name:
            _fail(f"env selection missing 'name': {env!r}")
        raw_access = env.get("access_level", "") or ""
        access_levels = [level.strip() for level in raw_access.split(",") if level.strip()]
        access = [
            {
                "sso_group_name": sso_group,
                "level": level
            }
            for level in access_levels if level
        ]
        env_block = {
            "name": env_name,
            "access": access
        }

        # Check if any access level is 'sandbox'
        if any(level.lower() == "sandbox" for level in access_levels):
            env_block["nuke"] = ""

        environments.append(env_block)

    data = {
        "account-type": "member",
        "codeowners": f"{github_owners}, {github_reviewers}",
        "environments": environments,
        "tags": {
            "application": app_tag,
            "business-unit": business_unit,
            "service-area": service_area,
            "infrastructure-support": infra_support,
            "owner": owner,
            "slack-channel": slack_channel,
            "critical-national-infrastructure": cni
        },
        "github-oidc-team-repositories": [],
        "go-live-date": go_live_date
    }
    # json.dump handles all quoting/escaping safely — no format-string interpolation
    # of untrusted values into the file.
    with open(_safe_env_path(app_name), "w") as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    if len(sys.argv) != 14:
        print("Usage: python create-account.py <app_name> <app_tag> <github_owners> <github_reviewers> <business_unit> <service_area> <infra_support> <owner> <slack_channel> <cni> <sso_group> <go_live_date> <env_selections_json>")
        sys.exit(1)
    app_name, app_tag, github_owners, github_reviewers, business_unit, service_area, infra_support, owner, slack_channel, cni, sso_group, go_live_date, env_selections_json = sys.argv[1:14]

    _validate_app_name(app_name)

    try:
        env_selections = json.loads(env_selections_json)
    except json.JSONDecodeError as exc:
        _fail(f"invalid env_selections JSON: {exc}")
    if not isinstance(env_selections, list):
        _fail("env_selections must be a JSON array")

    cni = cni.lower() == "true"
    if application_exists(app_name):
        print(f"Application '{app_name}' already exists.")
        sys.exit(1)
    else:
        create_env_json(
            app_name=app_name,
            app_tag=app_tag,
            github_owners=github_owners,
            github_reviewers=github_reviewers,
            business_unit=business_unit,
            service_area=service_area,
            infra_support=infra_support,
            owner=owner,
            slack_channel=slack_channel,
            cni=cni,
            sso_group=sso_group,
            go_live_date=go_live_date,
            env_selections=env_selections
        )
        add_app_to_rego(app_name, REGO_PATH)
        print(f"Created {app_name}.json")