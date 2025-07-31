import os
import json

ENV_DIR = "environments"

def application_exists(app_name):
    # Check for file existence
    target_file = os.path.join(ENV_DIR, f"{app_name}.json")
    if os.path.exists(target_file):
        return True
    # Optionally, check inside all files for duplicate "application" tags
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

def create_env_json(app_name, business_unit, infra_support, owner, slack_channel, cni, sso_group, go_live_date):
    data = {
        "account-type": "member",
        "environments": [
            {
                "name": "development",
                "access": [
                    {
                        "sso_group_name": sso_group,
                        "level": "developer"
                    }
                ]
            }
        ],
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

# Example usage:
app_name = "example"  # Replace with value from issue
if application_exists(app_name):
    print(f"Application '{app_name}' already exists.")
else:
    create_env_json(
        app_name=app_name,
        business_unit="Platforms",
        infra_support="modernisation-platform@digital.justice.gov.uk",
        owner="Modernisation Platform: modernisation-platform@digital.justice.gov.uk",
        slack_channel="modernisation-platform",
        cni=False,
        sso_group="modernisation-platform",
        go_live_date=""
    )
    print(f"Created {app_name}.json")