import json
import os
import sys
from notifications_python_client.notifications import NotificationsAPIClient

# Function to retrieve email from JSON file
def get_email(json_file_name):
    # Construct the path to the JSON file
    json_file = os.path.join("environments", f"{json_file_name}")
    # Check if the JSON file exists
    if not os.path.exists(json_file):
        return None
    # Open and read the JSON file
    with open(json_file, 'r') as f:
        json_file_data = json.load(f)
    # Retrieve the email address from JSON data
    return json_file_data.get("tags", {}).get("infrastructure-support")

# Main function to send notifications
def main(file_names):
    # Retrieve API key and template ID from environment variables
    api_key = os.environ["API_KEY"]
    template_id = os.environ["TEMPLATE_ID"]
    # Create a NotificationsAPIClient instance
    client = NotificationsAPIClient(api_key=api_key)
    # Iterate over each JSON file name provided as arguments
    for json_file_name in file_names:
        email_address=get_email(json_file_name)
        print(f"Email sending to: {email_address}")
        # Send email notification using NotificationsAPIClient
        notification = client.send_email_notification(
            template_id=template_id,
            email_address=email_address,
            personalisation={"file_name": json_file_name}
        )

if __name__ == "__main__":
    arg = sys.argv[1]
    file_names = arg.split(",")
    main(file_names)
