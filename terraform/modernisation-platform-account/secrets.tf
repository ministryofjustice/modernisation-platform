# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

# Core CI User
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "ci_iam_user_keys" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "ci_iam_user_keys"
  description = "Access keys for the CI user, this secret is used by GitHub to set the correct repository secrets."
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "ci_iam_user_keys" {
  secret_id = aws_secretsmanager_secret.ci_iam_user_keys.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.ci.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.ci.secret
  })
}

# Member CI user
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "member_ci_iam_user_keys" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "member_ci_iam_user_keys"
  description = "Access keys for the CI user, this secret is used by GitHub to set the correct repository secrets."
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "member_ci_iam_user_keys" {
  secret_id = aws_secretsmanager_secret.member_ci_iam_user_keys.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.member-ci.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.member-ci.secret
  })
}

# Slack channel modernisation-platform-notifications webhook url for sending notifications to slack
# Not adding a secret version as this url is provided by slack and cannot be added programatically
# Secret should be manually set in the console.
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "slack_webhook_url" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "slack_webhook_url"
  description = "Slack channel modernisation-platform-notifications webhook url for sending notifications to slack"
  tags        = local.tags
}

# Get the map of pagerduty integration keys
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  name = "pagerduty_integration_keys"
}

data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}
