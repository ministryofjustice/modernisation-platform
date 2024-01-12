# Get modernisation account id from ssm parameter
data "aws_ssm_parameter" "modernisation_platform_account_id" {
  name = "modernisation_platform_account_id"
}

# Create a new secret in AWS SecretsManager for Gov.UK Notify API key
resource "aws_secretsmanager_secret" "govuk_notify_api_key" {
  count = terraform.workspace == "data-platform-apps-and-tools-production" ? 1 : 0
  
  name = "gov-uk-notify/production/api-key"
}

# Email secret for Lambda function
resource "aws_secretsmanager_secret" "email_secret" {
  name = "jml/email"
}
data "aws_secretsmanager_secret" "environment_management" {
  provider = aws.modernisation-platform
  name     = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}
