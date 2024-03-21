# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  provider = aws.modernisation-platform
  name     = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

# Get the map of pagerduty integration keys
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-platform
  name     = "pagerduty_integration_keys"
}

data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}

# Data for Firehose Endpoint URL & Key that are held in secrets manager.

data "aws_secretsmanager_secret" "xsiam_secret_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_secrets"
}

data "aws_secretsmanager_secret_version" "xsiam_secret_arn_version" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.xsiam_secret_arn.id
}
