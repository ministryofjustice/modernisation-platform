# Slack channel modernisation-platform-notifications webhook url for sending notifications to slack
# Not adding a secret version as this url is provided by slack and cannot be added programatically
# Secret should be manually set in the console.
resource "aws_kms_key" "secrets_key" {
  description             = "AWS Secretsmanager CMK"
  policy                  = data.aws_iam_policy_document.kms_secrets_key.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "secrets_key" {
  name          = "alias/secrets_key"
  target_key_id = aws_kms_key.secrets_key.id
}

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

resource "aws_secretsmanager_secret" "slack_webhook_url" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "slack_webhook_url"
  description = "Slack channel modernisation-platform-notifications webhook url for sending notifications to slack"
  kms_key_id  = aws_kms_key.secrets_key.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}

# Github CI user PAT
# Not adding a secret version as this url is generated in Github cannot be added programatically
# Secret should be manually set in the console.
resource "aws_secretsmanager_secret" "github_ci_user_pat" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "github_ci_user_pat"
  description = "GitHub CI user PAT used for generated resources in GitHub via Terraform"
  kms_key_id  = aws_kms_key.secrets_key.id
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
  kms_key_id  = aws_kms_key.secrets_key.id
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
  kms_key_id  = aws_kms_key.secrets_key.id
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
  kms_key_id  = aws_kms_key.secrets_key.id
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
  kms_key_id  = aws_kms_key.secrets_key.id
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
resource "aws_secretsmanager_secret" "circleci" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "mod-platform-circleci"
  description = "CircleCI organisation ID for ministryofjustice, used for OIDC IAM policies"
  kms_key_id  = aws_kms_key.secrets_key.id

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

# Secrets for the XIAM data transfers. Note that the secrets contained in here are provided by Technology Services and so cannot be rotated unless initiated by them.
# Secrets should be manually set in the console.

resource "aws_secretsmanager_secret" "xsiam_secrets" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  name        = "xsiam_secrets"
  description = "Secret that holds the preprod & prod XSIAM endpoint values & keys for the firewall inspection & vpc flow log transfers"
  kms_key_id  = aws_kms_key.secrets_key.id
  tags        = local.tags
  replica {
    region = local.replica_region
  }
}


