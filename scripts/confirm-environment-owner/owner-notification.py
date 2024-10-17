import os
import sys
import argparse
from notifications_python_client.notifications import NotificationsAPIClient

# Sends an email using Gov Notify.
# We pass in three arguments - the environment name, the owner email address and the issue URL.
# Using argparse instead of sys.argv.

def send_email(env_name, issue_url, email_address):
    """
    Sends an email notification using the Notify service.
    
    Args:
        env_name: The name of the environment.
        issue_url: The URL of the issue to include in the email.
        email_address: The email address of the owner.
    """
    api_key = os.environ.get("API_KEY")
    template_id = os.environ.get("TEMPLATE_ID")
    if not api_key or not template_id:
        print("Error: API_KEY and TEMPLATE_ID must be set in environment variables.")
        sys.exit(1)
    
    client = NotificationsAPIClient(api_key=api_key)

    personalisation = {
        "env_name": env_name,
        "issue_url": issue_url
    }
    
    # Send the email
    try:
        response = client.send_email_notification(
            email_address=email_address,
            template_id=template_id,
            personalisation=personalisation
        )
        print(f"Email successfully sent to {email_address}. Response: {response}")
    except Exception as e:
        print(f"Failed to send email: {e}")
        sys.exit(1)

def main():

    parser = argparse.ArgumentParser(
        description="Send an email using the Notify API, with environment name, issue URL, and email address."
    )
    parser.add_argument("env_name", type=str, help="The environment name (e.g., development, production)")
    parser.add_argument("issue_url", type=str, help="The URL of the issue to include in the email")
    parser.add_argument("email_address", type=str, help="The email address to send the notification to")

    args = parser.parse_args()

    send_email(args.env_name, args.issue_url, args.email_address)

if __name__ == "__main__":
    main()
