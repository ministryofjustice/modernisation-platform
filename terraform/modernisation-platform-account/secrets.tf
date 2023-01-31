# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
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

# Github CI user PAT
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "github_ci_user_pat" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "github_ci_user_pat"
  description = "GitHub CI user PAT used for generated resources in GitHub via Terraform"
  tags        = local.tags
}

# Github CI user password
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "github_ci_user_password" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "github_ci_user_password"
  description = "GitHub CI user password"
  tags        = local.tags
}

# Account IDs to be excluded from auto-nuke
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "nuke_account_blocklist" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "nuke_account_blocklist"
  description = "Account IDs to be excluded from auto-nuke. AWS-Nuke (https://github.com/rebuy-de/aws-nuke) requires at least one Account ID to be present in this blocklist, while it is recommended to add every production account to this blocklist."
  tags        = local.tags
}

# Account IDs to be auto-nuked on weekly basis
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "nuke_account_ids" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  name        = "nuke_account_ids"
  description = "Account IDs to be auto-nuked on weekly basis. CAUTION: Any account ID you add here will be automatically nuked! This secret is used by GitHub actions job nuke.yml inside the environments repo, to find the Account IDs to be nuked."
  tags        = local.tags
}

# Get the map of pagerduty integration keys
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  name = "pagerduty_integration_keys"
}

data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}
