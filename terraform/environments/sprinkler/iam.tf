# OIDC resources

module "github-oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=84a83751b5289f363a728eb181470b59fc5e2899" # v3.0.1
  additional_permissions      = data.aws_iam_policy_document.oidc_deny_specific_actions.json
  additional_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  github_repositories         = ["ministryofjustice/modernisation-platform:*"]
  tags_common                 = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix                 = ""
}

#trivy:ignore:AVD-AWS-0345: Required for OIDC role to access Terraform state in S3
data "aws_iam_policy_document" "oidc_deny_specific_actions" {
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid       = "AllowOIDCToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }

  statement {
    sid       = "AllowOIDCReadState"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/*", "arn:aws:s3:::modernisation-platform-terraform-state/"]
    actions   = ["s3:List*"]
  }

  statement {
    sid    = "AllowOIDCWriteState"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/single-sign-on/terraform.tfstate",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/bootstrap/*/sprinkler-development/terraform.tfstate"
    ]
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject"
    ]
  }

  statement {
    sid    = "AllowOIDCDeleteLock"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/single-sign-on/*.tflock",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/bootstrap/*/sprinkler-development/*.tflock"
    ]
    actions = ["s3:DeleteObject"]
  }
}

module "github_actions_test_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=62b8a16c73d8e4422cd81923e46948e8f4b5cf48" # v3.2.0
  github_repositories = ["ministryofjustice/modernisation-platform"]
  role_name           = "github-actions-test"
  tags                = { "Name" = "GitHub Actions Test" }
}

resource "aws_iam_role" "terraform_plan_role" {
  name = "terraform-plan-role"

  # Trust relationship policy allowing github-action-test to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::${local.environment_management.account_ids["sprinkler-development"]}:role/github-actions-test"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_plan_role_readonly" {
  role       = aws_iam_role.terraform_plan_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
#trivy:ignore:AVD-AWS-0345: Required for test OIDC role to access Terraform state in S3
data "aws_iam_policy_document" "oidc_deny_specific_actions_test" {
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  # Allow OIDC role to decrypt using KMS
  statement {
    sid       = "AllowOIDCToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }

  # Allow OIDC role to list S3 objects in a specific bucket
  statement {
    sid    = "AllowOIDCReadState"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/*",
      "arn:aws:s3:::modernisation-platform-terraform-state/"
    ]
    actions = ["s3:List*"]
  }

  # Allow OIDC role to delete specific S3 lock files
  statement {
    sid    = "AllowOIDCDeleteLock"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/single-sign-on/*.tflock",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/bootstrap/*/sprinkler-development/*.tflock"
    ]
    actions = ["s3:DeleteObject"]
  }
}

resource "aws_iam_policy" "oidc_deny_specific_actions_test" {
  name        = "github-actions-test"
  description = "Policy for allowing specific OIDC actions"
  policy      = data.aws_iam_policy_document.oidc_deny_specific_actions_test.json
}

resource "aws_iam_role_policy_attachment" "terraform_plan_role_custom" {
  role       = aws_iam_role.terraform_plan_role.name
  policy_arn = aws_iam_policy.oidc_deny_specific_actions_test.arn
}

resource "aws_iam_role" "terraform_apply_role" {
  name = "terraform-apply-role"

  # Trust relationship policy allowing github-action-test to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::${local.environment_management.account_ids["sprinkler-development"]}:role/github-actions-test"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_apply_role" {
  # checkov:skip=CKV_AWS_274: "AdministratorAccess is required for Terraform Apply role"
  role       = aws_iam_role.terraform_apply_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_apply_role_custom" {
  role       = aws_iam_role.terraform_apply_role.name
  policy_arn = data.aws_iam_policy.github_actions.arn
}

data "aws_iam_policy" "github_actions" {
  name = "github-actions"
}
