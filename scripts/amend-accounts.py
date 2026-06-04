import os
import json
import sys

ENV_DIR = "environments"

def append_access(app_name, sso_group, env_selections):
    filename = os.path.join(ENV_DIR, f"{app_name}.json")
    if not os.path.exists(filename):
        print(f"Error: {filename} does not exist.")
        return

    with open(filename, "r") as f:
        data = json.load(f)

    environments = data.get("environments", [])
    env_names = [env["name"] for env in environments]

    for env_sel in env_selections:
        env_name = env_sel["name"]
        # Split access levels by comma and strip whitespace
        access_levels = [level.strip() for level in env_sel.get("access_level", "").split(",") if level.strip()]
        new_access = [
            {
                "sso_group_name": sso_group,
                "level": level
            }
            for level in access_levels if level
        ]
        env_found = False
        for env in environments:
            if env["name"] == env_name:
                env_found = True
                existing_access = env.setdefault("access", [])
                for access_entry in new_access:
                    if not any(
                        a["sso_group_name"] == access_entry["sso_group_name"] and a["level"] == access_entry["level"]
                        for a in existing_access
                    ):
                        existing_access.append(access_entry)
                break
        if not env_found:
            environments.append({
                "name": env_name,
                "access": new_access
            })

    data["environments"] = environments

    with open(filename, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Updated access for environments in {filename}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python amend-accounts.py <app_name> <sso_group> <env_selections_json>")
        sys.exit(1)
    app_name = sys.argv[1]
    sso_group = sys.argv[2]
    env_selections_json = sys.argv[3]
    env_selections = json.loads(env_selections_json)
    append_access(app_name, sso_group, env_selections)
    print(f"Amended {app_name}.json")