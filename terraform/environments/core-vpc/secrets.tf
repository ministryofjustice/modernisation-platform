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


# For the Firehose Endpoints - More will be added for the other endpoints
data "aws_secretsmanager_secret" "preprod_network_secret_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_preprod_network_secret"
}

data "aws_secretsmanager_secret_version" "preprod_network_secret_arn_version" {
  provider = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.preprod_network_secret_arn.id
}

