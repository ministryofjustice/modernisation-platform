# Environment Management
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "environment_management" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key

  provider    = aws.modernisation-platform
  name        = "environment_management"
  description = "IDs for AWS-specific resources for environment management, such as organizational unit IDs"
  tags        = local.environments
}

resource "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = aws_secretsmanager_secret.environment_management.id
  secret_string = jsonencode(merge(
    local.environment_management,
    { account_ids : module.environments.environment_account_ids }
  ))
  depends_on = [data.aws_secretsmanager_secret_version.environment_management]
}

data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = aws_secretsmanager_secret.environment_management.id
}

locals {
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
}
