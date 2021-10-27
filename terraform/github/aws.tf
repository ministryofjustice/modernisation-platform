# This gets the AWS access keys for Core CI/CD from AWS Secrets Manager to set as repository secrets.
data "aws_secretsmanager_secret" "ci_iam_user_keys" {
  name = "ci_iam_user_keys"
}

data "aws_secretsmanager_secret_version" "ci_iam_user_keys" {
  secret_id = data.aws_secretsmanager_secret.ci_iam_user_keys.id
}

# This gets the AWS access keys for Member CI/CD from AWS Secrets Manager to set as repository secrets.
data "aws_secretsmanager_secret" "member_ci_iam_user_keys" {
  name = "member_ci_iam_user_keys"
}

data "aws_secretsmanager_secret_version" "member_ci_iam_user_keys" {
  secret_id = data.aws_secretsmanager_secret.member_ci_iam_user_keys.id
}
locals {
  ci_iam_user_keys        = jsondecode(data.aws_secretsmanager_secret_version.ci_iam_user_keys.secret_string)
  member_ci_iam_user_keys = jsondecode(data.aws_secretsmanager_secret_version.member_ci_iam_user_keys.secret_string)
}

# Get the slack webhook url
data "aws_secretsmanager_secret" "slack_webhook_url" {
  name = "slack_webhook_url"
}

data "aws_secretsmanager_secret_version" "slack_webhook_url" {
  secret_id = data.aws_secretsmanager_secret.slack_webhook_url.id
}
