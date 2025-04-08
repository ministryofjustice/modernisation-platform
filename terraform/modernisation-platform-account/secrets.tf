# Slack channel modernisation-platform-notifications webhook url for sending notifications to slack
# Not adding a secret version as this url is provided by slack and cannot be added programatically
# Secret should be manually set in the console.
resource "aws_kms_key" "secrets_key_multi_region" {
  description             = "AWS Secretsmanager CMK"
  policy                  = data.aws_iam_policy_document.kms_secrets_key.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  multi_region            = true
}

resource "aws_kms_alias" "secrets_key_multi_region" {
  name          = "alias/secrets-key-multi-region"
  target_key_id = aws_kms_key.secrets_key_multi_region.id
}

resource "aws_kms_replica_key" "secrets_key_multi_region_replica" {
  description             = "AWS Secretsmanager CMK replica key"
  deletion_window_in_days = 30
  primary_key_arn         = aws_kms_key.secrets_key_multi_region.arn
  provider                = aws.modernisation-platform-eu-west-1
}

resource "aws_kms_alias" "secrets_key_multi_region_replica" {
  name          = "alias/secrets-key-multi-region-replica"
  target_key_id = aws_kms_replica_key.secrets_key_multi_region_replica.id
}

data "aws_iam_policy_document" "kms_secrets_key" {
  #cannot reference secret in resources for statement as this causes cyclic error
  #checkov:skip=CKV_AWS_108: Cannot set resource as not known at time document is created, causing a cyclic error
  #checkov:skip=CKV_AWS_109: "Constraint is via only mp ou condition"
  #checkov:skip=CKV_AWS_111: "Constraint is via only mp ou condition"
  #checkov:skip=CKV_AWS_356: Policy is attached to a resource
  statement {
    sid    = "AllowManagementAccountAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id, data.aws_organizations_organization.root_account.master_account_id]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowModernisationPlatformAccountsToDecrypt"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:Decrypt*"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }
}

# CircleCI Organisation ID
resource "aws_secretsmanager_secret" "circleci" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "mod-platform-circleci"
  description = "CircleCI organisation ID for ministryofjustice, used for OIDC IAM policies"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id

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

# Github CI user PAT
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
resource "aws_secretsmanager_secret" "github_ci_user_pat" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "github_ci_user_pat"
  description = "GitHub CI user PAT used for generated resources in GitHub via Terraform"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Github CI user environments repo PAT
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
resource "aws_secretsmanager_secret" "github_ci_user_environments_repo_pat" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "github_ci_user_environments_repo_pat"
  description = "This PAT token is used in reusable pipelines of the modernisation-platform-environments repository. This is so that the CI user can post comments in PRs, e.g. tf plan/apply output. Expires on Tue, Apr 9 2024."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Github CI user password
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
resource "aws_secretsmanager_secret" "github_ci_user_password" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "github_ci_user_password"
  description = "GitHub CI user password"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Github CI user environments repo PAT
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
resource "aws_secretsmanager_secret" "modernisation_pat_multirepo" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "modernisation_pat_multirepo"
  description = "This PAT token is used in pipelines of the modernisation-platform repository. This is so that the CI user can read/write issues and read/update github secrets."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret" "gov_uk_notify_api_key" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "gov_uk_notify_api_key"
  description = "API key for accessing the GOV.UK Notify service for sending email notifications"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Account IDs to be excluded from auto-nuke
resource "aws_secretsmanager_secret" "nuke_account_blocklist" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nuke_account_blocklist"
  description = "Account IDs to be excluded from auto-nuke. AWS-Nuke (https://github.com/rebuy-de/aws-nuke) requires at least one Account ID to be present in this blocklist, while it is recommended to add every production account to this blocklist."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Account IDs to be auto-nuked on weekly basis
resource "aws_secretsmanager_secret" "nuke_account_ids" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nuke_account_ids"
  description = "Account IDs to be auto-nuked on weekly basis. CAUTION: Any account ID you add here will be automatically nuked! This secret is used by GitHub actions job nuke.yml inside the environments repo, to find the Account IDs to be nuked."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret" "slack_webhook_url" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "slack_webhook_url"
  description = "Slack channel modernisation-platform-notifications webhook url for sending notifications to slack"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret" "slack_webhooks" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "slack_webhooks"
  description = "Used for sending notifications to specified Slack channels when environment JSON files are modified"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret" "testing_test_access_key_id" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "testing_test_access_key_id"
  description = "Key ID used by unit tests in github repositories to access the testing-test account"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret" "testing_test_access_key" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "testing_test_access_key"
  description = "Key value used by unit tests in github repositories to access the testing-test account"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
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
