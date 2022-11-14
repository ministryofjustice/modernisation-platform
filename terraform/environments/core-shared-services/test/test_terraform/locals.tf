locals {
  function_name          = "instance-scheduler-lambda-function"
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
}