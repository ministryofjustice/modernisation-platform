# Get modernisation account id from ssm parameter
data "aws_ssm_parameter" "modernisation_platform_account_id" {
  name = "modernisation_platform_account_id"
}

# Get secret by arn for environment management
data "aws_secretsmanager_secret" "environment_management" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  provider = aws.modernisation-platform
  name     = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

// Secret for the tactical products database access
resource "aws_secretsmanager_secret" "rds_db_credentials" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  kms_key_id              = data.aws_kms_key.general_shared.arn
  name                    = "tactical-products-db-secrets"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "tactical_products_rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_db_credentials.id
  secret_string = jsonencode({ "" : "" })
}