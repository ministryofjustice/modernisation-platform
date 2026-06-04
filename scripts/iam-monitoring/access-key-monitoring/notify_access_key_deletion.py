import sys
import os
from notifications_python_client.notifications import NotificationsAPIClient

# Define the email subject and body with placeholders
EMAIL_SUBJECT = "Deletion of Inactive Access Keys"
EMAIL_BODY_TEMPLATE = """
Hi ((username)),

We are writing to inform you that the access keys associated with your AWS IAM user account, which is part of the Super Admin group, have been found to be inactive for either not being used or being inactive for more than 30 days. As a security measure, inactive access keys are periodically reviewed and removed to prevent accidental leakage or unintended use.

As a result, the access keys linked to your account have been deactivated and removed from your user profile. If you require access to AWS services, please generate new access keys as needed.

Thank you for your attention to this matter.

Best regards,

Modernisation Platform Team
"""

def process_users(user_list_file):
    """
    This function reads a file containing a list of superadmin inactive users whose 
    access keys have not been used for more than 30 days. The access keys for these 
    users have been deleted, and notifications will be sent to inform them.

    Args:
        user_list_file (str): The path to the file containing the list of inactive users.
    """
    # Get API key and template ID from environment variables
    api_key = os.environ.get("API_KEY")
    template_id = os.environ.get("TEMPLATE_ID")
    
    if not api_key or not template_id:
        print("Error: API_KEY and TEMPLATE_ID must be set in environment variables.")
        sys.exit(1)
    
    # Initialize the Notifications client
    client = NotificationsAPIClient(api_key=api_key)

    with open(user_list_file, 'r') as file:
        users = [line.strip() for line in file.readlines()]
        # Process each user in the list
    for user in users:
        # Replace periods with spaces, capitalize each word, and take the first word as the username
        username = user.replace(".", " ").title().split()[0]
        # Construct the email address for the user
        email = user + "@digital.justice.gov.uk"
        
        # Prepare dynamic personalisation
        personalisation = {
            "username": username,
            "subject": EMAIL_SUBJECT,
            "message": EMAIL_BODY_TEMPLATE.replace("((username))", username)
        }

        # Send notification
        try:
            notification = client.send_email_notification(
                template_id=template_id,
                email_address=email,
                personalisation=personalisation
            )
            print(f"Notification sent to {username}. Response ID: {notification['id']}")
        except Exception as e:
            print(f"Failed to send notification to {username}: {e}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python notify_access_key_deletion.py <user_list_file>")
        sys.exit(1)

    user_list_file = sys.argv[1]
    process_users(user_list_file)
