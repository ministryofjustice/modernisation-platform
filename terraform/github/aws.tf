# This gets the AWS access keys for CI/CD from AWS Secrets Manager to set as repository secrets.
data "aws_secretsmanager_secret" "ci_iam_user_keys" {
  name = "ci_iam_user_keys"
}

data "aws_secretsmanager_secret_version" "ci_iam_user_keys" {
  secret_id = data.aws_secretsmanager_secret.ci_iam_user_keys.id
}

locals {
  ci_iam_user_keys = jsondecode(data.aws_secretsmanager_secret_version.ci_iam_user_keys.secret_string)
}
