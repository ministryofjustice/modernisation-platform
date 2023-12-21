# Slack channel modernisation-platform-notifications webhook url for sending notifications to slack
# Not adding a secret version as this url is provided by slack and cannot be added programatically
# Secret should be manually set in the console.
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "slack_webhook_url" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "slack_webhook_url"
  description = "Slack channel modernisation-platform-notifications webhook url for sending notifications to slack"
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Github CI user PAT
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "github_ci_user_pat" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "github_ci_user_pat"
  description = "GitHub CI user PAT used for generated resources in GitHub via Terraform"
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Github CI user environments repo PAT
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "github_ci_user_environments_repo_pat" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "github_ci_user_environments_repo_pat"
  description = "This PAT token is used in reusable pipelines of the modernisation-platform-environments repository. This is so that the CI user can post comments in PRs, e.g. tf plan/apply output. Expires on Tue, Apr 9 2024."
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Github CI user password
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "github_ci_user_password" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "github_ci_user_password"
  description = "GitHub CI user password"
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Account IDs to be excluded from auto-nuke
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "nuke_account_blocklist" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nuke_account_blocklist"
  description = "Account IDs to be excluded from auto-nuke. AWS-Nuke (https://github.com/rebuy-de/aws-nuke) requires at least one Account ID to be present in this blocklist, while it is recommended to add every production account to this blocklist."
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Account IDs to be auto-nuked on weekly basis
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "nuke_account_ids" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nuke_account_ids"
  description = "Account IDs to be auto-nuked on weekly basis. CAUTION: Any account ID you add here will be automatically nuked! This secret is used by GitHub actions job nuke.yml inside the environments repo, to find the Account IDs to be nuked."
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Reflection of what is in member accounts, needed here as well so that the same code works for collaborators
resource "aws_ssm_parameter" "modernisation_platform_account_id" {
  #checkov:skip=CKV_AWS_337: Standard key is fine here
  name  = "modernisation_platform_account_id"
  type  = "SecureString"
  value = data.aws_caller_identity.current.id
  tags  = local.tags
}

# CircleCI Organisation ID
#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "circleci" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "mod-platform-circleci"
  description = "CircleCI organisation ID for ministryofjustice, used for OIDC IAM policies"
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret_version" "circleci" {
  secret_id = aws_secretsmanager_secret.circleci.id
  secret_string = jsonencode({
    organisation_id = "CHANGE_ME_IN_THE_CONSOLE" # change this value manually in the console once the secret is created
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# Data call to fetch changed value
data "aws_secretsmanager_secret_version" "circleci" {
  secret_id = aws_secretsmanager_secret.circleci.id
}

