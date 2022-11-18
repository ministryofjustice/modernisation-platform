# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}


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

# This gets the AWS access keys for Testing CI/CD from AWS Secrets Manager to set as repository secrets.
data "aws_secretsmanager_secret" "testing_ci_iam_user_keys" {
  provider = aws.testing-test
  name     = "testing_ci_iam_user_keys"
}

data "aws_secretsmanager_secret_version" "testing_ci_iam_user_keys" {
  provider  = aws.testing-test
  secret_id = data.aws_secretsmanager_secret.testing_ci_iam_user_keys.id
}
locals {
  ci_iam_user_keys         = jsondecode(data.aws_secretsmanager_secret_version.ci_iam_user_keys.secret_string)
  member_ci_iam_user_keys  = jsondecode(data.aws_secretsmanager_secret_version.member_ci_iam_user_keys.secret_string)
  testing_ci_iam_user_keys = jsondecode(data.aws_secretsmanager_secret_version.testing_ci_iam_user_keys.secret_string)
}

# Get the slack webhook url
data "aws_secretsmanager_secret" "slack_webhook_url" {
  name = "slack_webhook_url"
}

data "aws_secretsmanager_secret_version" "slack_webhook_url" {
  secret_id = data.aws_secretsmanager_secret.slack_webhook_url.id
}

# Get the pagerduty api token
data "aws_secretsmanager_secret" "pagerduty_token" {
  name = "pagerduty_token"
}

data "aws_secretsmanager_secret_version" "pagerduty_token" {
  secret_id = data.aws_secretsmanager_secret.pagerduty_token.id
}
# Organizations root acct
data "aws_organizations_organization" "root_account" {}