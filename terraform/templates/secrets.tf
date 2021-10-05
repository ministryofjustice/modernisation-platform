# Get secret by arn for environment management
data "aws_ssm_parameter" "environment_management_arn" {
  name = "environment_management_arn"
}

data "aws_secretsmanager_secret" "environment_management" {
  arn = data.aws_ssm_parameter.environment_management_arn.value
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}
