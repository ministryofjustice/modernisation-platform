import argparse
import json
import os
import re
import sys
import uuid


ENV_DIR = "environments"
SCHEMA_VERSION = 2
VALID_ENVIRONMENTS = {"development", "test", "preproduction", "production"}
VALID_BUSINESS_UNITS = {
    "Central Digital",
    "HMPPS",
    "OPG",
    "LAA",
    "HMCTS",
    "CICA",
    "Platforms",
    "Technology Services",
}
VALID_ACCESS_LEVELS = {
    "view-only",
    "secrets-manager-editor",
    "developer",
    "sandbox",
    "migration",
    "instance-management",
    "instance-access",
    "security-audit",
    "reporting-operations",
    "data-engineer",
    "fleet-manager",
    "s3-upload",
    "ssm-session-access",
    "data-scientist",
}

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
    new_accounts_block = ",\n    ".join(f'"{a}"' for a in accounts_sorted)
    new_content = content[:match.start(2)] + new_accounts_block + content[match.end(2):]


    with open(rego_path, "w") as f:
        f.write(new_content)
    print(f"Added {app_name} to rego accounts list in alphabetical order.")

def application_exists(app_name, env_dir=ENV_DIR):
    target_file = os.path.join(env_dir, f"{app_name}.json")
    if os.path.exists(target_file):
        return True
    for fname in os.listdir(env_dir):
        if fname.endswith(".json"):
            with open(os.path.join(env_dir, fname)) as f:
                try:
                    data = json.load(f)
                    if data.get("tags", {}).get("application", "").lower() == app_name.lower():
                        return True
                except Exception:
                    continue
    return False

def create_env_json(app_name, app_tag, github_owners, github_reviewers, business_unit, service_area, infra_support, owner, slack_channel, cni, go_live_date, env_selections, env_dir=ENV_DIR):
    environments = []
    for env in env_selections:
        access = [
            {
                "sso_group_name": entry["sso_group_name"],
                "level": entry["level"],
            }
            for entry in env["access"]
        ]
        env_block = {
            "name": env["name"],
            "access": access
        }

        # Check if any access level is 'sandbox'
        if any(entry["level"] == "sandbox" for entry in access):
            env_block["nuke"] = ""

        environments.append(env_block)

    data = {"account-type": "member"}
    if github_owners:
        data["codeowners"] = github_owners
    if github_reviewers:
        data["github_action_reviewer"] = github_reviewers
    data.update({
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
    })
    with open(os.path.join(env_dir, f"{app_name}.json"), "w") as f:
        json.dump(data, f, indent=2)

def require_string(value, field, allow_empty=False):
    if not isinstance(value, str) or (not allow_empty and not value.strip()):
        raise ValueError(f"{field} must be a non-empty string")
    return value.strip()


def require_team_slugs(values, field):
    if not isinstance(values, list) or not all(isinstance(value, str) and value.strip() for value in values):
        raise ValueError(f"{field} must be an array of non-empty strings")
    normalized = [value.strip() for value in values]
    if not all(re.fullmatch(r"[a-z0-9-]+", value) for value in normalized):
        raise ValueError(f"{field} must contain lowercase GitHub team slugs")
    return normalized


def split_team_slugs(value, field):
    values = [team.strip() for team in value.split(",") if team.strip()]
    return require_team_slugs(values, field)


def load_request(request_path):
    with open(request_path) as request_file:
        request = json.load(request_file)

    if not isinstance(request, dict):
        raise ValueError("request must be a JSON object")
    if request.get("schemaVersion") != SCHEMA_VERSION:
        raise ValueError(f"schemaVersion must be {SCHEMA_VERSION}")

    request_id = require_string(request.get("requestId"), "requestId")
    try:
        uuid.UUID(request_id)
    except ValueError as error:
        raise ValueError("requestId must be a UUID") from error
    application = request.get("application")
    tags = request.get("tags")
    networking = request.get("networking")
    environments = request.get("environments")

    if not isinstance(application, dict):
        raise ValueError("application must be an object")
    if not isinstance(tags, dict):
        raise ValueError("tags must be an object")
    if not isinstance(networking, dict):
        raise ValueError("networking must be an object")
    if not isinstance(environments, list) or not environments:
        raise ValueError("environments must be a non-empty array")

    app_name = require_string(application.get("name"), "application.name")
    if len(app_name) > 30 or not re.fullmatch(r"[a-z0-9-]+", app_name):
        raise ValueError("application.name must be 30 characters or fewer and contain only lowercase letters, numbers and hyphens")

    app_tag = require_string(application.get("tag"), "application.tag")
    require_string(application.get("description"), "application.description")

    codeowners = require_team_slugs(application.get("codeowners", []), "application.codeowners")
    github_reviewers = require_team_slugs(
        application.get("githubActionReviewers", []),
        "application.githubActionReviewers",
    )

    environment_names = set()
    env_selections = []
    for index, environment in enumerate(environments):
        if not isinstance(environment, dict):
            raise ValueError(f"environments[{index}] must be an object")
        name = require_string(environment.get("name"), f"environments[{index}].name").lower()
        if name not in VALID_ENVIRONMENTS:
            raise ValueError(f"environments[{index}].name is not supported")
        if name in environment_names:
            raise ValueError(f"environment '{name}' is duplicated")
        environment_names.add(name)

        access_entries = environment.get("access")
        if not isinstance(access_entries, list) or not access_entries:
            raise ValueError(f"environments[{index}].access must be a non-empty array")

        access = []
        access_levels = set()
        for access_index, access_entry in enumerate(access_entries):
            if not isinstance(access_entry, dict):
                raise ValueError(f"environments[{index}].access[{access_index}] must be an object")
            level = require_string(
                access_entry.get("level"),
                f"environments[{index}].access[{access_index}].level",
            )
            if level not in VALID_ACCESS_LEVELS:
                raise ValueError(f"environments[{index}].access[{access_index}].level is not supported")
            if level in access_levels:
                raise ValueError(f"access level '{level}' is duplicated in environment '{name}'")
            if name != "development" and level == "sandbox":
                raise ValueError("sandbox access is only supported in development")
            access_levels.add(level)
            access.append({
                "level": level,
                "sso_group_name": require_string(
                    access_entry.get("ssoGroupName"),
                    f"environments[{index}].access[{access_index}].ssoGroupName",
                ),
            })

        env_selections.append({"name": name, "access": access})

    business_unit = require_string(tags.get("businessUnit"), "tags.businessUnit")
    if business_unit not in VALID_BUSINESS_UNITS:
        raise ValueError("tags.businessUnit is not supported")
    service_area = require_string(tags.get("serviceArea"), "tags.serviceArea")
    infra_support = require_string(tags.get("infrastructureSupport"), "tags.infrastructureSupport")
    if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", infra_support):
        raise ValueError("tags.infrastructureSupport must be an email address")
    owner = require_string(tags.get("owner"), "tags.owner")
    slack_channel = require_string(tags.get("slackChannel", ""), "tags.slackChannel", allow_empty=True)
    if "#" in slack_channel:
        raise ValueError("tags.slackChannel must not include '#'")

    isolated = networking.get("isolated")
    if not isinstance(isolated, bool):
        raise ValueError("networking.isolated must be a boolean")
    require_string(networking.get("userConnectivity"), "networking.userConnectivity")

    cni = request.get("criticalNationalInfrastructure", False)
    if not isinstance(cni, bool):
        raise ValueError("criticalNationalInfrastructure must be a boolean")
    go_live_date = request.get("goLiveDate", "")
    require_string(go_live_date, "goLiveDate", allow_empty=True)

    return {
        "request_id": request_id,
        "app_name": app_name,
        "app_tag": app_tag,
        "github_owners": codeowners,
        "github_reviewers": github_reviewers,
        "business_unit": business_unit,
        "service_area": service_area,
        "infra_support": infra_support,
        "owner": owner,
        "slack_channel": slack_channel,
        "cni": cni,
        "go_live_date": go_live_date,
        "env_selections": env_selections,
        "isolated": isolated,
    }


def create_account(account, env_dir=ENV_DIR, rego_path=None):
    app_name = account["app_name"]
    if application_exists(app_name, env_dir):
        raise ValueError(f"Application '{app_name}' already exists.")

    create_env_json(
        app_name=app_name,
        app_tag=account["app_tag"],
        github_owners=account["github_owners"],
        github_reviewers=account["github_reviewers"],
        business_unit=account["business_unit"],
        service_area=account["service_area"],
        infra_support=account["infra_support"],
        owner=account["owner"],
        slack_channel=account["slack_channel"],
        cni=account["cni"],
        go_live_date=account["go_live_date"],
        env_selections=account["env_selections"],
        env_dir=env_dir,
    )
    if rego_path is None:
        rego_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "policies", "environments", "expected.rego"))
    add_app_to_rego(app_name, rego_path)
    print(f"Created {app_name}.json")


def legacy_account(arguments):
    if len(arguments) != 13:
        raise ValueError("legacy mode requires 13 positional arguments")
    app_name, app_tag, github_owners, github_reviewers, business_unit, service_area, infra_support, owner, slack_channel, cni, sso_group, go_live_date, env_selections_json = arguments
    if len(app_name) > 30 or not re.fullmatch(r"[a-z0-9-]+", app_name):
        raise ValueError("app_name must be 30 characters or fewer and contain only lowercase letters, numbers and hyphens")
    if business_unit not in VALID_BUSINESS_UNITS:
        raise ValueError("business_unit is not supported")
    if "#" in slack_channel:
        raise ValueError("slack_channel must not include '#'")
    if cni.lower() not in {"true", "false"}:
        raise ValueError("cni must be true or false")
    env_selections = json.loads(env_selections_json)
    if not isinstance(env_selections, list) or not env_selections:
        raise ValueError("env_selections_json must be a non-empty array")
    environment_names = set()
    normalized_env_selections = []
    for index, environment in enumerate(env_selections):
        if not isinstance(environment, dict):
            raise ValueError(f"env_selections_json[{index}] must be an object")
        name = environment.get("name")
        if name not in VALID_ENVIRONMENTS:
            raise ValueError(f"env_selections_json[{index}].name is not supported")
        if name in environment_names:
            raise ValueError(f"environment '{name}' is duplicated")
        environment_names.add(name)
        access_levels = [level.strip() for level in environment.get("access_level", "").split(",") if level.strip()]
        if not access_levels or not all(level in VALID_ACCESS_LEVELS for level in access_levels):
            raise ValueError(f"env_selections_json[{index}].access_level is invalid")
        if name != "development" and "sandbox" in access_levels:
            raise ValueError("sandbox access is only supported in development")
        normalized_env_selections.append({
            "name": name,
            "access": [
                {"sso_group_name": sso_group, "level": level}
                for level in access_levels
            ],
        })
    return {
        "app_name": app_name,
        "app_tag": app_tag,
        "github_owners": split_team_slugs(github_owners, "github_owners"),
        "github_reviewers": split_team_slugs(github_reviewers, "github_reviewers"),
        "business_unit": business_unit,
        "service_area": service_area,
        "infra_support": infra_support,
        "owner": owner,
        "slack_channel": slack_channel,
        "cni": cni.lower() == "true",
        "go_live_date": go_live_date,
        "env_selections": normalized_env_selections,
    }


def main(arguments=None):
    parser = argparse.ArgumentParser(description="Generate files for a Modernisation Platform account request")
    parser.add_argument("--request", help="Path to a structured self-service request JSON file")
    parser.add_argument("legacy_arguments", nargs="*")
    args = parser.parse_args(arguments)

    if args.request and args.legacy_arguments:
        parser.error("--request cannot be combined with positional arguments")

    try:
        account = load_request(args.request) if args.request else legacy_account(args.legacy_arguments)
        create_account(account)
    except (OSError, json.JSONDecodeError, ValueError) as error:
        parser.error(str(error))


if __name__ == "__main__":
    main(sys.argv[1:])