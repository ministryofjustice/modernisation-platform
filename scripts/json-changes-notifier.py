import json
import os
import sys
from notifications_python_client.notifications import NotificationsAPIClient

# Define email subject and body
EMAIL_SUBJECT = "Update: ((file_name)) File Changed"
EMAIL_BODY = """\
Hello Team,

This is to inform you that changes have been detected in the JSON file: ((file_name)) within the environments folder of the Modernisation Platform repository. You can view the changes directly by following this [link](https://github.com/ministryofjustice/modernisation-platform/blob/main/environments/((file_name))).

If you have any questions or need further assistance, please contact [#ask-modernisation-platform](https://moj.enterprise.slack.com/archives/C01A7QK5VM1) or reply to this email.

Best regards,

Modernisation Platform Team
"""

def get_email(json_file_name):
    # Construct the path to the JSON file
    """
    Retrieves the email address from the corresponding JSON file.
    Args:
        json_file_name: Name of the JSON file.
    Returns:
        The email address if found, otherwise None.
    """
    json_file = os.path.join("environments", f"{json_file_name}")
    # Check if the JSON file exists
    if not os.path.exists(json_file):
        return None
    # Open and read the JSON file
    with open(json_file, "r") as f:
        json_file_data = json.load(f)
    # Retrieve the email address from JSON data
    return json_file_data.get("tags", {}).get("infrastructure-support")

# Main function to send notifications
def main(file_names):
    # Retrieve API key and template ID from environment variables
    """
    Sends email notifications for each JSON file with detected changes.
    Args:
        file_names: List of JSON file names.
    """
    api_key = os.environ.get("GOV_UK_NOTIFY_API_KEY")
    template_id = os.environ.get("TEMPLATE_ID")
    # Create a NotificationsAPIClient instance
    client = NotificationsAPIClient(api_key=api_key)
    # Iterate over each JSON file name provided as arguments
    for json_file_name in file_names:
        email_address = get_email(json_file_name)
        if not email_address:
            print(f"No email address found for file: {json_file_name}")
            continue

        try:
            subject = EMAIL_SUBJECT.replace("((file_name))", json_file_name)
            message = EMAIL_BODY.replace("((file_name))", json_file_name)

            client.send_email_notification(
                template_id=template_id,
                email_address=email_address,
                personalisation={
                    "subject": subject,
                    "message": message,
                },
            )
            print(f"Notification sent for {json_file_name} to {email_address}")
        except Exception as e:
            print(f"Failed to send notification for {json_file_name} to {email_address}: {e}")

if __name__ == "__main__":
    file_names = sys.argv[1:]
    main(file_names)
    