data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "root_account" {}

# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

data "aws_iam_policy_document" "pagerduty_secret" {
  #cannot reference secret in resources for statement as this causes cyclic error
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_356: Policy is attached to a resource
  statement {
    sid    = "ReadOnlyFromModernisationPlatformOU"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:GetResourcePolicy", "secretsmanager:DescribeSecret"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }
}

data "aws_iam_policy_document" "pagerduty_kms" {
  #cannot reference secret in resources for statement as this causes cyclic error
  #checkov:skip=CKV_AWS_108
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