#### Testing New Separate Roles for Github Actions Plan and Apply ####

#trivy:ignore:AVD-AWS-0345: Required for GitHub Actions to access Terraform state in S3
module "github_actions_testing_plan_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform-environments"]
  role_name           = "github-actions-testing-plan"
  policy_jsons        = [data.aws_iam_policy_document.testing_oidc_assume_plan_role_member.json]
  tags                = { "Name" = "GitHub Actions Testing Plan" }
}

data "aws_iam_policy_document" "testing_oidc_assume_plan_role_member" {
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_108: "Allowing secretsmanager:GetSecretValue with open resource due to specific use case"
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
  }

  statement {
    sid    = "AssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::*:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.aws_organizations_root_account_id}:role/ModernisationPlatformSSOAdministrator"
    ]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values = [
        "${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"
      ]
    }
  }

  statement {
    sid       = "AllowOIDCReadState"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/*", "arn:aws:s3:::modernisation-platform-terraform-state/"]
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
  }

  statement {
    sid       = "AllowOIDCDeleteLock"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/*.tflock"]
    actions   = ["s3:DeleteObject"]
  }
}

# OIDC Provider for GitHub Actions Testing Apply
#trivy:ignore:AVD-AWS-0345: Required for GitHub Actions to access Terraform state in S3
module "github_actions_testing_apply_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform-environments"]
  role_name           = "github-actions-testing-apply"
  policy_arns         = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  policy_jsons        = [data.aws_iam_policy_document.testing_apply_oidc_deny_specific_actions.json]
  subject_claim       = "ref:refs/heads/main"
  tags                = { "Name" = "GitHub Actions Testing Apply" }
}

data "aws_iam_policy_document" "testing_apply_oidc_deny_specific_actions" {
  statement {
    effect = "Deny"
    actions = [
      "iam:ChangePassword",
      "iam:CreateLoginProfile"
    ]
    resources = ["*"]
  }
}