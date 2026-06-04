# OIDC resources

module "github-oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=5dc9bc211d10c58de4247fa751c318a3985fc87b" # v4.0.0
  additional_permissions      = data.aws_iam_policy_document.oidc_deny_specific_actions.json
  additional_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  github_repositories         = ["ministryofjustice/modernisation-platform:*", "ministryofjustice/modernisation-platform-environments:*"]
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

# Terraform Read Only Role for use from Modernisation-Platform-Environments

module "github_actions_environments_read_only" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform-environments"]
  role_name           = "github-actions-environments-read-only"
  policy_jsons        = [data.aws_iam_policy_document.github_actions_environments_read_only.json]
  tags                = local.tags
}

data "aws_iam_policy_document" "github_actions_environments_read_only" {
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_108: "Allowing secretsmanager:GetSecretValue with open resource due to specific use case"
  statement {
    sid       = "AllowDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "secretsmanager:GetSecretValue"
    ]
  }

  statement {
    sid    = "AllowAssumeRoles"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_ssm_parameter.modernisation_platform_account_id.value}:role/modernisation-account-limited-read-member-access",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modernisation-account-limited-read-member-access",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modify-dns-records",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-sandbox"]}:role/member-delegation-garden-sandbox"
    ]
  }

  statement {
    sid       = "AllowOIDCReadState"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/*", "arn:aws:s3:::modernisation-platform-terraform-state/"]
    actions   = ["s3:List*"]
  }

  statement {
    sid       = "AllowOIDCDeleteLock"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/sprinkler/*.tflock"]
    actions = [
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject"
    ]
  }
}

# Terraform For Non-Prod Envs Only.

module "github_actions_environments_dev_test" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform-environments"]
  role_name           = "github-actions-environments-dev-test"
  policy_jsons        = [data.aws_iam_policy_document.github_actions_environments_dev_test.json]
  tags                = local.tags
}

#trivy:ignore:AVD-AWS-0345: Required for OIDC role to access Terraform state in S3
data "aws_iam_policy_document" "github_actions_environments_dev_test" {
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid       = "AllowOIDCToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }

  statement {
    sid    = "AllowAssumeRoles"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_ssm_parameter.modernisation_platform_account_id.value}:role/modernisation-account-limited-read-member-access",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modernisation-account-limited-read-member-access",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modify-dns-records",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-sandbox"]}:role/member-delegation-garden-sandbox"
    ]
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
      "arn:aws:s3:::modernisation-platform-terraform-state/single-sign-on/terraform.*",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/bootstrap/*/sprinkler-development/terraform.*",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/members/sprinkler/sprinkler-development/terraform.*"
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
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/bootstrap/*/sprinkler-development/*.tflock",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/members/sprinkler/sprinkler-development/*.tflock"
    ]
    actions = ["s3:DeleteObject"]
  }
}