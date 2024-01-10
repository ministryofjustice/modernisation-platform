# Get modernisation account id from ssm parameter
data "aws_ssm_parameter" "modernisation_platform_account_id" {
  name = "modernisation_platform_account_id"
}

# Create a new secret in AWS SecretsManager for Gov.UK Notify
resource "aws_secretsmanager_secret" "gov_uk_notify_secret" {
  name = "gov_uk_notify_secret"
}

# Add the API key to the secret
resource "aws_secretsmanager_secret_version" "gov_uk_notify_secret_version" {
  secret_id     = aws_secretsmanager_secret.gov_uk_notify_secret.id
  secret_string = "API_KEY_FROM_1PASSWORD"
}

# Get secret by arn for environment management
data "aws_secretsmanager_secret" "environment_management" {
  provider = aws.modernisation-platform
  name     = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}
