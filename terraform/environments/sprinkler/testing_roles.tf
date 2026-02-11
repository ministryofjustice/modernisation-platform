#### Testing New Separate Roles for Github Actions Plan and Apply ####

#trivy:ignore:AVD-AWS-0345: Required for GitHub Actions to access Terraform state in S3
module "github_actions_nonprod_testing_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform-environments"]
  role_name           = "github-actions-testing-nonprod"
  policy_jsons        = [data.aws_iam_policy_document.testing_nonprod_oidc_assume_role_member.json]
  tags                = { "Name" = "GitHub Actions Testing NonProd" }
}

data "aws_iam_policy_document" "testing_nonprod_oidc_assume_role_member" {
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
      "arn:aws:iam::*:role/MemberInfrastructureAccess",
      "arn:aws:iam::${local.environment_management.modernisation_platform_account_id}:role/modernisation-account-limited-read-member-access"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.root_account.id]
    }
  }

  statement {
    sid       = "AllowOIDCReadState"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/*", "arn:aws:s3:::modernisation-platform-terraform-state/"]
    actions   = ["s3:List*"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["environments/members/sprinkler/*"]
    }
  }

  statement {
    sid       = "AllowOIDGetUpdate"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/sprinkler/*","arn:aws:s3:::modernisation-platform-terraform-state/environments/members/sprinkler/"]
    actions = [
      "s3:Get*",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
  }

  statement {
    sid       = "AllowOIDCDeleteLock"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/sprinkler/*.tflock"]
    actions   = ["s3:DeleteObject"]
  }
}

# OIDC Provider for GitHub Actions Testing Prod
#trivy:ignore:AVD-AWS-0345: Required for GitHub Actions to access Terraform state in S3
module "github_actions_prod_testing_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform-environments"]
  role_name           = "github-actions-testing-prod"
  policy_arns         = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  policy_jsons        = [data.aws_iam_policy_document.testing_prod_oidc_assume_role_member.json]
  subject_claim       = "ref:refs/heads/main"
  tags                = { "Name" = "GitHub Actions Testing Prod" }
}

data "aws_iam_policy_document" "testing_prod_oidc_assume_role_member" {
  statement {
    effect = "Deny"
    actions = [
      "iam:ChangePassword",
      "iam:CreateLoginProfile"
    ]
    resources = ["*"]
  }
}