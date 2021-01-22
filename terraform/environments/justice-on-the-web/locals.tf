locals {
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
}
