# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

locals {
  testing_ci_iam_user_keys = jsondecode(aws_secretsmanager_secret_version.testing_ci_iam_user_keys.secret_string)
}

# Get the slack webhook url
data "aws_secretsmanager_secret" "slack_webhook_url" {
  name = "slack_webhook_url"
}

data "aws_secretsmanager_secret_version" "slack_webhook_url" {
  secret_id = data.aws_secretsmanager_secret.slack_webhook_url.id
}

# Get the pagerduty api token
data "aws_secretsmanager_secret" "pagerduty_token" {
  name = "pagerduty_token"
}

data "aws_secretsmanager_secret_version" "pagerduty_token" {
  secret_id = data.aws_secretsmanager_secret.pagerduty_token.id
}
