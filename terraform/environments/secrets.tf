# Environment Management
resource "aws_secretsmanager_secret" "environment_management" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not possible
  provider    = aws.modernisation-platform
  name        = "environment_management"
  description = "IDs for AWS-specific resources for environment management, such as organizational unit IDs"
  kms_key_id  = aws_kms_key.environment_management.id
  policy      = data.aws_iam_policy_document.environment_management.json
  tags        = local.environments
  replica {
    region = "eu-west-1"
  }
}

resource "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = aws_secretsmanager_secret.environment_management.id
  secret_string = jsonencode(merge(
    local.environment_management,
    { account_ids : module.environments.environment_account_ids }
  ))
  depends_on = [data.aws_secretsmanager_secret_version.environment_management]
}

data "aws_iam_policy_document" "environment_management" {

  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_108: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  statement {
    sid    = "ReadOnlyFromModernisationPlatformOU"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.modernisation_platform_ou_id}/*"]
    }
  }
}

# Environment secret KMS key
resource "aws_kms_key" "environment_management" {
  provider                = aws.modernisation-platform
  description             = "environment-management"
  policy                  = data.aws_iam_policy_document.kms_environment_management.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "environment_management" {
  provider      = aws.modernisation-platform
  name          = "alias/environment-management"
  target_key_id = aws_kms_key.environment_management.id
}

# Environment secret KMS key multi-Region
resource "aws_kms_key" "environment_management_multi_region" {
  provider                = aws.modernisation-platform
  description             = "environment-management-multi-region"
  policy                  = data.aws_iam_policy_document.kms_environment_management.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  multi_region            = true
}

resource "aws_kms_alias" "environment_management_multi_region" {
  provider      = aws.modernisation-platform
  name          = "alias/environment-management-multi-region"
  target_key_id = aws_kms_key.environment_management_multi_region.id
}

data "aws_iam_policy_document" "kms_environment_management" {

  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  statement {
    sid    = "Allow management access of the key to the root and modernisation platform account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id, local.modernisation_platform_account.id]
    }
  }
  statement {
    sid    = "Allow key decryption for modernisation platform ou members"
    effect = "Allow"
    actions = [
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.modernisation_platform_ou_id}/*"]
    }
  }
}

data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = aws_secretsmanager_secret.environment_management.id
}

locals {
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
}

# Store environment management secret in Github secrets
resource "github_actions_secret" "environment_management" {
  for_each = toset(["modernisation-platform-environments", "modernisation-platform", "modernisation-platform-ami-builds", "modernisation-platform-configuration-management"])
  # checkov:skip=CKV_SECRET_6: "secret_name is not a secret"
  secret_name = "MODERNISATION_PLATFORM_ENVIRONMENTS"
  repository  = each.key
  plaintext_value = jsonencode(merge(
    local.environment_management,
    { account_ids : module.environments.environment_account_ids }
  ))
}

resource "github_actions_secret" "autonuke_blocklist" {
  # checkov:skip=CKV_SECRET_6: "secret_name is not a secret"
  secret_name     = "MODERNISATION_PLATFORM_AUTONUKE_BLOCKLIST"
  repository      = "modernisation-platform-environments"
  plaintext_value = jsonencode(module.environments.environment_nuke_blocklist_accounts)
}

resource "github_actions_secret" "autonuke_rebuild" {
  # checkov:skip=CKV_SECRET_6: "secret_name is not a secret"
  secret_name     = "MODERNISATION_PLATFORM_AUTONUKE_REBUILD"
  repository      = "modernisation-platform-environments"
  plaintext_value = jsonencode(concat(module.environments.environment_rebuild_after_nuke_accounts, ["cooker-development"]))
}

resource "github_actions_secret" "autonuke" {
  # checkov:skip=CKV_SECRET_6: "secret_name is not a secret"
  secret_name = "MODERNISATION_PLATFORM_AUTONUKE"
  repository  = "modernisation-platform-environments"
  # testing-test, cooker-development, and example-development are internal test account which are not sandpits but require nuking.
  plaintext_value = jsonencode(concat(module.environments.environment_nuke_accounts, ["testing-test", "cooker-development", "example-development"]))
}