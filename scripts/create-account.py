import os
import json
import sys
import re

def add_app_to_rego(app_name, rego_path):
    with open(rego_path, "r") as f:
        content = f.read()

    # Find the accounts array
    match = re.search(r'("accounts":\s*\[\s*)(.*?)(\s*\])', content, re.DOTALL)
    if not match:
        print("Could not find accounts array in rego file.")
        return

    # Extract existing accounts
    accounts_block = match.group(2)
    accounts = re.findall(r'"([^"]+)"', accounts_block)
    if app_name in accounts:
        print(f"{app_name} already in accounts list.")
        return

    # Add and sort
    accounts.append(app_name)
    accounts_sorted = sorted(accounts, key=lambda x: x.lower())

    # Rebuild accounts block
    new_accounts_block = "\n    " + ",\n    ".join(f'"{a}"' for a in accounts_sorted) + "\n"
    new_content = content[:match.start(2)] + new_accounts_block + content[match.end(2):]

    with open(rego_path, "w") as f:
        f.write(new_content)
    print(f"Added {app_name} to rego accounts list in alphabetical order.")

ENV_DIR = "environments"

def application_exists(app_name):
    target_file = os.path.join(ENV_DIR, f"{app_name}.json")
    if os.path.exists(target_file):
        return True
    for fname in os.listdir(ENV_DIR):
        if fname.endswith(".json"):
            with open(os.path.join(ENV_DIR, fname)) as f:
                try:
                    data = json.load(f)
                    if data.get("tags", {}).get("application", "").lower() == app_name.lower():
                        return True
                except Exception:
                    continue
    return False

def create_env_json(app_name, business_unit, infra_support, owner, slack_channel, cni, sso_group, go_live_date, env_selections):
    environments = []
    for env in env_selections:
        # Split access levels by comma and strip whitespace
        access_levels = [level.strip() for level in env["access_level"].split(",") if level.strip()]
        access = [
            {
                "sso_group_name": sso_group,
                "level": level
            }
            for level in access_levels if level
        ]
        environments.append({
            "name": env["name"],
            "access": access
        })
    data = {
        "account-type": "member",
        "environments": environments,
        "tags": {
            "application": app_name,
            "business-unit": business_unit,
            "infrastructure-support": infra_support,
            "owner": owner,
            "slack-channel": slack_channel,
            "critical-national-infrastructure": cni
        },
        "github-oidc-team-repositories": [],
        "go-live-date": go_live_date
    }
    with open(os.path.join(ENV_DIR, f"{app_name}.json"), "w") as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    if len(sys.argv) < 10:
        print("Usage: python create-account.py <app_name> <business_unit> <infra_support> <owner> <slack_channel> <cni> <sso_group> <go_live_date> <env_selections_json>")
        sys.exit(1)
    app_name, business_unit, infra_support, owner, slack_channel, cni, sso_group, go_live_date, env_selections_json = sys.argv[1:10]
    cni = cni.lower() == "true"
    env_selections = json.loads(env_selections_json)
    if application_exists(app_name):
        print(f"Application '{app_name}' already exists.")
        sys.exit(1)
    else:
        create_env_json(
            app_name=app_name,
            business_unit=business_unit,
            infra_support=infra_support,
            owner=owner,
            slack_channel=slack_channel,
            cni=cni,
            sso_group=sso_group,
            go_live_date=go_live_date,
            env_selections=env_selections
        )
        # Add app name to rego file
        rego_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "policies", "environments", "expected.rego"))
        add_app_to_rego(app_name, rego_path)
        print(f"Created {app_name}.json")