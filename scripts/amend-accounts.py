import os
import json
import sys

ENV_DIR = "environments"

def append_access(app_name, env_name, new_access):
    filename = os.path.join(ENV_DIR, f"{app_name}.json")
    if not os.path.exists(filename):
        print(f"Error: {filename} does not exist.")
        return

    with open(filename, "r") as f:
        data = json.load(f)

    environments = data.get("environments", [])
    env_found = False

    for env in environments:
        if env["name"] == env_name:
            env_found = True
            existing_access = env.setdefault("access", [])
            # Only add if not already present (by sso_group_name and level)
            for access_entry in new_access:
                if not any(
                    a["sso_group_name"] == access_entry["sso_group_name"] and a["level"] == access_entry["level"]
                    for a in existing_access
                ):
                    existing_access.append(access_entry)
            break

    if not env_found:
        # Create new environment section
        environments.append({
            "name": env_name,
            "access": new_access
        })

    data["environments"] = environments

    with open(filename, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Updated access for '{env_name}' in {filename}")

# Example usage:
if __name__ == "__main__":
    # Example: python append-access.py example test
    # Simulate new access from issue
    new_access = [
        {
            "sso_group_name": "modernisation-platform",
            "level": "instance-management"
        }
    ]
    if len(sys.argv) < 3:
        print("Usage: python append-access.py <app_name> <env_name>")
        sys.exit(1)
    app_name = sys.argv[1]
    env_name = sys.argv[2]
    append_access(app_name, env_name, new_access)