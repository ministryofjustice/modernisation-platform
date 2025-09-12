import sys
import os
import json
import re

def add_account_to_network(app_name, business_unit, env):
    """
    Adds the app_name-environment entry to the accounts list
    in the correct environments-networks/<business_unit>-<env>.json file.
    """
    # Construct the network file path
    network_file = f"environments-networks/{business_unit.lower()}-{env}.json"
    if not os.path.exists(network_file):
        print(f"Network file {network_file} does not exist.")
        sys.exit(1)

    # Load the JSON data from the network file
    with open(network_file, "r") as f:
        data = json.load(f)

    # Get the accounts list from the general subnet set
    accounts = data["cidr"]["subnet_sets"]["general"]["accounts"]
    entry = f"{app_name}-{env}"
    if entry in accounts:
        print(f"{entry} already present in {network_file}")
        return

    # Add the new entry and sort alphabetically
    accounts.append(entry)
    accounts.sort(key=lambda x: x.lower())

    # Write the updated data back to the file
    with open(network_file, "w") as f:
        json.dump(data, f, indent=2)
    print(f"Added {entry} to {network_file}")

def add_account_to_rego(app_name, business_unit, env, rego_path):
    """
    Adds the app_name-environment entry to the correct accounts array
    in the expected.rego policy file for the given subnet set.
    """
    subnet_set = f'{business_unit.lower()}-{env}'
    account_entry = f'{app_name}-{env}'

    # Read the rego policy file as text
    with open(rego_path, "r") as f:
        content = f.read()

    # Regex to find the correct subnet_set and its accounts array
    pattern = re.compile(
        rf'("{subnet_set}":\s*\{{\s*"general":\s*\{{[^{{}}]*?"accounts":\s*\[(.*?)\])',
        re.DOTALL
    )
    match = pattern.search(content)
    if not match:
        print(f"Could not find subnet_set {subnet_set} in {rego_path}")
        return

    # Extract and update the accounts list
    accounts_block = match.group(2)
    accounts = re.findall(r'"([^"]+)"', accounts_block)
    if account_entry in accounts:
        print(f"{account_entry} already present in {rego_path}")
        return

    # Add the new entry and sort alphabetically
    accounts.append(account_entry)
    accounts_sorted = sorted(accounts, key=lambda x: x.lower())
    new_accounts_block = "\n              " + ",\n              ".join(f'"{a}"' for a in accounts_sorted) + "\n            "
    new_content = content[:match.start(2)] + new_accounts_block + content[match.end(2):]

    # Write the updated rego policy back to the file
    with open(rego_path, "w") as f:
        f.write(new_content)
    print(f"Added {account_entry} to {rego_path}")

# Main script entry point
if __name__ == "__main__":
    # Check for minimum required arguments
    if len(sys.argv) < 4:
        print("Usage: python network-setup.py <app_name> <business_unit> <environment>")
        sys.exit(1)
    app_name = sys.argv[1]
    business_unit = sys.argv[2]
    env = sys.argv[3]

    # Add the account to the network JSON file
    add_account_to_network(app_name, business_unit, env)

    # Build the path to the expected.rego policy file
    rego_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "policies", "networking", "expected.rego"))

    # Add the account to the rego policy file
    add_account_to_rego(app_name, business_unit, env, rego_path)