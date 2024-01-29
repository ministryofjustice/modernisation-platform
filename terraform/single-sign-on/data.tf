# # Get AWS SSO instances. Note that this returns a list,
# # although AWS SSO only supports singular SSO instances.
data "aws_ssoadmin_instances" "default" {
  provider = aws.sso-management
}

# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name     = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}
