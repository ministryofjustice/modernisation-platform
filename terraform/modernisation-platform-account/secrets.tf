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

# Look up environments remote state to get aws nuke lists
data "terraform_remote_state" "environments" {
  backend = "s3"
  config = {
    bucket = "modernisation-platform-terraform-state"
    key    = "environments/terraform.tfstate"
    region = "eu-west-2"
  }
}

# Account IDs to be excluded from auto-nuke
resource "aws_secretsmanager_secret" "nuke_account_blocklist" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nuke_account_blocklist"
  description = "Account IDs to be excluded from auto-nuke. This secret is used by GitHub actions job awsnuke.yml inside the environments repo."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret_version" "nuke_account_blocklist" {
  secret_id = aws_secretsmanager_secret.nuke_account_blocklist.id
  secret_string = jsonencode({
    blocklist = data.terraform_remote_state.environments.outputs.environment_nuke_blocklist_accounts
  })
}

# Account IDs to be auto-nuked on weekly basis
resource "aws_secretsmanager_secret" "nuke_account_ids" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nuke_account_ids"
  description = "Account IDs to be auto-nuked on weekly basis. This secret is used by GitHub actions job awsnuke.yml inside the environments repo."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret_version" "nuke_account_ids" {
  secret_id = aws_secretsmanager_secret.nuke_account_ids.id
  secret_string = jsonencode({
    nuke_accounts = data.terraform_remote_state.environments.outputs.environment_nuke_accounts
  })
}

# Account IDs to be rebuilt after being nuked
resource "aws_secretsmanager_secret" "nuke_rebuild_account_ids" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nuke_rebuild_account_ids"
  description = "Account IDs to be rebuilt after being nuked. This secret is used by GitHub actions job awsnuke.yml inside the environments repo."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}
resource "aws_secretsmanager_secret_version" "nuke_rebuild_account_ids" {
  secret_id = aws_secretsmanager_secret.nuke_rebuild_account_ids.id
  secret_string = jsonencode({
    rebuild_accounts = data.terraform_remote_state.environments.outputs.environment_rebuild_after_nuke_accounts
  })
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

resource "aws_secretsmanager_secret" "securityhub_slack_webhooks" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "securityhub_slack_webhooks"
  description = "Stores Slack channel webhook URLs for sending Security Hub findings notifications"
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

resource "aws_secretsmanager_secret" "secrets-fetch-decrypt-passphrase" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "secrets-fetch-decrypt-passphrase"
  description = "Used by the reusable secrets workflows as the passphrase"
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

data "aws_kms_alias" "environment_management" {
  name = "alias/environment-management-multi-region"
}

resource "aws_secretsmanager_secret" "nonmp_account_ids" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "nonmp-account-ids"
  description = "Map of account IDs not present in the environment_management secret (non-MP accounts)"
  kms_key_id  = data.aws_kms_alias.environment_management.target_key_id
  tags        = local.tags
}

# Modernisation Platform Github App Private Key
resource "aws_secretsmanager_secret" "modernisation_platform_github_app_private_key" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "modernisation_platform_github_app_private_key"
  description = "The private key associated with the modernisation platform github app."
  kms_key_id  = aws_kms_key.secrets_key_multi_region.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}
resource "aws_secretsmanager_secret_version" "modernisation_platform_github_app_private_key" {
  secret_id     = aws_secretsmanager_secret.modernisation_platform_github_app_private_key.id
  secret_string = "Replace after build"
}
