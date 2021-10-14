# Environment Management
# Tfsec ignore
# - AWS095: No requirement currently to encrypt this secret with customer-managed KMS key
#tfsec:ignore:AWS095
resource "aws_secretsmanager_secret" "environment_management" {
  # checkov:skip=CKV_AWS_149:No requirement currently to encrypt this secret with customer-managed KMS key

  provider    = aws.modernisation-platform
  name        = "environment_management"
  description = "IDs for AWS-specific resources for environment management, such as organizational unit IDs"
  kms_key_id  = aws_kms_key.environment_management.id
  policy      = data.aws_iam_policy_document.environment_management.json
  tags        = local.environments
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

data "aws_iam_policy_document" "kms_environment_management" {

  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "policy is directly related to the resource"
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
      "kms:Decrypt*",
      "kms:GenerateDataKey"
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

#data.aws_organizations_organizational_units.root_ous.children["modernistion-platform"].id
data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.modernisation-platform
  secret_id = aws_secretsmanager_secret.environment_management.id
}

locals {
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
}
