# Status Page Email Subscription Management
# This automatically subscribes infrastructure-support email addresses from environments/*.json
# to the PagerDuty external status page

locals {
  # Additional emails to subscribe that aren't in environments/*.json files
  # Add any ad-hoc email addresses here as needed
  additional_subscriber_emails = [
    # Example: "team-name@justice.gov.uk",
    # Example: "external-team@example.com",
  ]

  # Read all environment JSON files
  environment_files = fileset("${path.module}/../../environments", "*.json")

  # Parse each file and extract infrastructure-support emails
  environment_configs = {
    for file in local.environment_files :
    file => jsondecode(file("${path.module}/../../environments/${file}"))
  }

  # Extract unique infrastructure-support emails (non-null only)
  infrastructure_support_emails = distinct(compact([
    for file, config in local.environment_configs :
    try(config.tags["infrastructure-support"], null)
  ]))

  # Combine emails from JSON files with additional hardcoded emails
  all_subscriber_emails = distinct(concat(
    local.infrastructure_support_emails,
    local.additional_subscriber_emails
  ))

  # Sort for consistent ordering and create a hash to detect ANY changes
  # This hash will change if:
  # - New emails are added
  # - Emails are removed
  # - Emails are modified
  # - New *.json files are added with infrastructure-support tags
  # - Additional emails are added/removed from the local
  emails_sorted = sort(local.all_subscriber_emails)
  emails_hash   = md5(jsonencode(local.emails_sorted))

}

# Execute subscription sync ONLY when the email list hash changes
# This will trigger when:
# - New email is added to any environments/*.json file
# - Email is removed from a file
# - Email address is modified
# - New *.json file is added with an infrastructure-support email
resource "null_resource" "sync_status_page_subscriptions" {
  triggers = {
    emails_hash = local.emails_hash
  }

  provisioner "local-exec" {
    command = "${path.module}/../../scripts/manage_status_page_subscriptions.sh"

    environment = {
      PAGERDUTY_TOKEN   = var.pagerduty_token
      STATUS_PAGE_ID    = var.pagerduty_status_page_id
      SUBSCRIBER_EMAILS = jsonencode(local.emails_sorted)
    }
  }
}

# Outputs for visibility
output "status_page_subscriber_count" {
  description = "Number of email addresses that should be subscribed to the status page"
  value       = length(local.all_subscriber_emails)
}

output "status_page_additional_emails_count" {
  description = "Number of additional hardcoded emails (before deduplication)"
  value       = length(local.additional_subscriber_emails)
}

output "status_page_subscribers_hash" {
  description = "Hash of current subscriber list (changes when list is modified)"
  value       = local.emails_hash
}

output "status_page_subscriber_emails" {
  description = "List of infrastructure-support emails that will be subscribed"
  value       = local.emails_sorted
  sensitive   = true
}
