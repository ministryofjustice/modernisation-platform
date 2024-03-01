import json
import sys

def get_email(account_name):
    email_mappings = {
        "equip": "modernisation-platform@digital.justice.gov.uk",
        "sprinkler": "modernisation-platform@digital.justice.gov.uk",
        "ppud": "modernisation-platform@digital.justice.gov.uk",
        "digital": "digitalprisonreporting@digital.justice.gov.uk",
        "data": "modernisation-platform@digital.justice.gov.uk",
        "portal": "aws-webops-laa@digital.justice.gov.uk",
        "electronic": "modernisation-platform@digital.justice.gov.uk",
        "delius": "probation-webops@digital.justice.gov.uk"
        # Add more mappings here if needed
    }
    for prefix, email in email_mappings.items():
        if account_name.startswith(prefix):
            return email
    return None

def main(collaborators_file, iam_users_file):
    with open(collaborators_file, 'r') as f:
        collaborators_data = json.load(f)
    
    with open(iam_users_file, 'r') as f:
        iam_users = [line.strip() for line in f.readlines()]

    user_emails = []
    for user in collaborators_data['users']:
        for account in user['accounts']:
            for iam_user in iam_users:
                if iam_user == user['username']:
                    email = get_email(account['account-name'])
                    if email:
                        user_emails.append({"username": user['username'], "email": email})

    for user in user_emails:
        print(user["username"], user["email"])

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py collaborators.json iam_users.list")
        sys.exit(1)

    collaborators_file = sys.argv[1]
    iam_users_file = sys.argv[2]
    main(collaborators_file, iam_users_file)
