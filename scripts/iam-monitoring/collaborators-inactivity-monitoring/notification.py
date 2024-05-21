import json
import os
import sys
from notifications_python_client.notifications import NotificationsAPIClient

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
  with open(account_file, 'r') as f:
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
  api_key = os.environ["API_KEY"]
  template_id = os.environ["TEMPLATE_ID"]
  client = NotificationsAPIClient(api_key=api_key)

  with open(collaborators_file, 'r') as f:
    collaborators_data = json.load(f)

  with open(iam_users_file, 'r') as f:
    iam_users = [line.strip() for line in f.readlines()]
    
  user_emails = []
  
  for user in collaborators_data['users']:
    for account in user['accounts']:
      account_name = account['account-name']
      # Extract the base account name without the environment suffix
      base_account_name = '-'.join(account_name.split('-')[:-1])
      for iam_user in iam_users:
        if iam_user == user['username']:
          email = get_email(base_account_name)
          if email:
            user_emails.append({"username": user['username'], "email": email})
  unique_emails = remove_duplicates(user_emails)

  for user in unique_emails:
    notification = client.send_email_notification(
            template_id=template_id,
            email_address=user["email"],
            personalisation={"username": user["username"]},
    )
  print("Notification sent to all users")

if __name__ == "__main__":
  if len(sys.argv) != 3:
    print("Usage: python script.py collaborators.json iam_users.list")
    sys.exit(1)
  collaborators_file = sys.argv[1]
  iam_users_file = sys.argv[2]
  main(collaborators_file, iam_users_file)
