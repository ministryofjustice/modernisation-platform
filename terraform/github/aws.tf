# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

locals {
  testing_ci_iam_user_keys = sensitive({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.testing_ci.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.testing_ci.secret
  })
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

# Get the pagerduty user api token
data "aws_secretsmanager_secret" "pagerduty_user_token" {
  name = "pagerduty_userapi_token"
}

data "aws_secretsmanager_secret_version" "pagerduty_user_token" {
  secret_id = data.aws_secretsmanager_secret.pagerduty_userapi_token.id
}


# Get the GitHub CI user PAT
data "aws_secretsmanager_secret" "github_ci_user_token" {
  name = "github_ci_user_pat"
}

data "aws_secretsmanager_secret_version" "github_ci_user_token" {
  secret_id = data.aws_secretsmanager_secret.github_ci_user_token.id
}

# Get the GitHub CI user environments repo PAT
data "aws_secretsmanager_secret" "github_ci_user_environments_repo_pat_token" {
  name = "github_ci_user_environments_repo_pat"
}

data "aws_secretsmanager_secret_version" "github_ci_user_environments_repo_pat_token" {
  secret_id = data.aws_secretsmanager_secret.github_ci_user_environments_repo_pat_token.id
}
