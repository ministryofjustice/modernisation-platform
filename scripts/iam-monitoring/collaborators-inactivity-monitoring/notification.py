import json
import os
import sys
from notifications_python_client.notifications import NotificationsAPIClient

# Define email subject and body
EMAIL_SUBJECT = "Action Required: Inactive IAM Collaborator User – ((username))"
EMAIL_BODY = """\
Hi Team,

We are contacting you regarding your IAM Collaborator user account in the Modernisation Platform account. Our records indicate that your IAM user account, ((username)), has been inactive for the past 90 days or more.

What you need to do:

To keep your account active, please log into the account within the next 30 days.

Important notes:

- If you no longer require your account, you can reply to this email with the username you wish to disable immediately. We will handle the deactivation process for you.
- User accounts that are not confirmed active through login within 30 days will be automatically disabled, including console access and all access keys.
- Disabled accounts will be permanently deleted 4 months after the date of this email.

Thank you for your attention to this matter.

Best regards,  
Modernisation Platform Team
"""

def get_email(account_name):
    """
    Retrieves email address from the corresponding JSON file based on account name.
    Args:
        account_name: The name of the account (without suffixes like -development).
    Returns:
        The email address if found, otherwise None.
    """
    account_file = os.path.join("environments", f"{account_name}.json")
    if not os.path.exists(account_file):
        return None
    with open(account_file, "r") as f:
        account_data = json.load(f)
    return account_data.get("tags", {}).get("infrastructure-support")

def remove_duplicates(user_emails):
    """
    Removes duplicate dictionaries from a list while preserving all unique emails for each username.
    Args:
        user_emails (list): A list of dictionaries containing username and email keys.
    Returns:
        list: A new list with unique dictionaries containing all emails per username.
    """
    seen_emails = set()
    unique_emails = []
    for user_email in user_emails:
        username = user_email["username"]
        email = user_email["email"]
        unique_key = f"{username}-{email}"
        if unique_key not in seen_emails:
            seen_emails.add(unique_key)
            unique_emails.append(user_email)
    return unique_emails

def main(collaborators_file, iam_users_file):
    """
    Reads user data from collaborators.json, IAM users from iam_users.list, and retrieves emails from account JSON files.
    Args:
        collaborators_file: Path to the collaborators.json file.
        iam_users_file: Path to the iam_users.list file.
    """
    api_key = os.environ["GOV_UK_NOTIFY_API_KEY"]
    template_id = os.environ["TEMPLATE_ID"]
    client = NotificationsAPIClient(api_key=api_key)

    with open(collaborators_file, "r") as f:
        collaborators_data = json.load(f)

    with open(iam_users_file, "r") as f:
        iam_users = [line.strip() for line in f.readlines()]

    user_emails = []

    for user in collaborators_data["users"]:
        for account in user["accounts"]:
            account_name = account["account-name"]
            # Extract the base account name without the environment suffix
            base_account_name = "-".join(account_name.split("-")[:-1])
            for iam_user in iam_users:
                if iam_user == user["username"]:
                    email = get_email(base_account_name)
                    if email:
                        user_emails.append({"username": user["username"], "email": email})
    unique_emails = remove_duplicates(user_emails)

    for user in unique_emails:
        try:
            subject = EMAIL_SUBJECT.replace("((username))", user["username"])
            message = EMAIL_BODY.replace("((username))", user["username"])

            notification = client.send_email_notification(
                template_id=template_id,
                email_address=user["email"],
                personalisation={
                    "subject": subject,
                    "message": message,
                },
            )
            print(f"Notification sent to {user['username']} at {user['email']}")
        except Exception as e:
            print(f"Failed to send notification to {user['username']} at {user['email']}: {e}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py collaborators.json iam_users.list")
        sys.exit(1)

    collaborators_file = sys.argv[1]
    iam_users_file = sys.argv[2]
    main(collaborators_file, iam_users_file)
