import sys
import os
from notifications_python_client import NotificationsAPIClient

def process_users(user_list_file):
    """
    This function reads a file containing a list of superadmin inactive users whose 
    access keys have not been used for more than 30 days. The access keys for these 
    users have been deleted, and notifications will be sent to inform them.

    Args:
        user_list_file (str): The path to the file containing the list of inactive users.
    """
    api_key = os.environ["api_key"]
    template_id = os.environ["template_id"]
    client = NotificationsAPIClient(api_key=api_key)

    with open(user_list_file, 'r') as file:
        users = [line.strip() for line in file.readlines()]
        # Process each user in the list
    for user in users:
        # Replace periods with spaces, capitalize each word, and take the first word as the username
        username = user.replace(".", " ").title().split()[0]
        # Construct the email address for the user
        email = user + "@digital.justice.gov.uk"
        # Send notification
        notification = client.send_email_notification(
            template_id=template_id,
            email_address=email,
            personalisation={"username": username}
        )
        print("Notification sent to", username)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python notify_access_key_deletion.py <user_list_file>")
        sys.exit(1)

    user_list_file = sys.argv[1]
    process_users(user_list_file)