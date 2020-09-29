# Environments management
resource "aws_secretsmanager_secret" "environments_management" {
  name        = "environments_management"
  description = "IDs for AWS-specific resources for environment management, such as account ID"
  tags        = local.environments
}

data "aws_secretsmanager_secret_version" "environments_management" {
  secret_id = aws_secretsmanager_secret.environments_management.id
}

locals {
  environments_management = jsondecode(data.aws_secretsmanager_secret_version.environments_management.secret_string)
}
