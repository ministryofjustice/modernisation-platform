locals {
  account_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), ""))
  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))
}

resource "aws_iam_account_alias" "alias" {
  count         = (local.account_data.account-type != "member-unrestricted") && !(contains(local.skip_alias, terraform.workspace)) ? 1 : 0
  provider      = aws.workspace
  account_alias = terraform.workspace
}

module "cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=ef80831bbc71e96733abb9ff32cc3f24bcc7e55f" #v3.0.0
  providers = {
    aws = aws.workspace
  }
  account_id             = local.modernisation_platform_account.id
  policy_arn             = "arn:aws:iam::aws:policy/AdministratorAccess"
  role_name              = "ModernisationPlatformAccess"
  additional_trust_roles = terraform.workspace == "testing-test" ? ["arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:user/testing-ci"] : []
}

# Create a parameter for the modernisation platform environment management secret ARN that can be used to gain
# access to the environments parameter when running a tf plan locally

resource "aws_ssm_parameter" "environment_management_arn" {
  #checkov:skip=CKV_AWS_337: Standard key is fine here
  provider = aws.workspace

  name  = "environment_management_arn"
  type  = "SecureString"
  value = data.aws_secretsmanager_secret.environment_management.arn

  tags = local.environments
}

# Create a parameter for the modernisation platform account id that can be used
# by providers in member accounts to assume a role in MP

resource "aws_ssm_parameter" "modernisation_platform_account_id" {
  #checkov:skip=CKV_AWS_337: Standard key is fine here
  provider = aws.workspace

  name  = "modernisation_platform_account_id"
  type  = "SecureString"
  value = local.environment_management.modernisation_platform_account_id

  tags = local.environments
}

# AWS Shield Advanced SRT (Shield Response Team) support role
module "shield_response_team_role" {
  # checkov:skip=CKV_TF_1:
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5"
  providers = {
    aws = aws.workspace
  }
  trusted_role_services = ["drt.shield.amazonaws.com"]

  create_role       = true
  role_name         = "AWSSRTSupport"
  role_requires_mfa = false

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSShieldDRTAccessPolicy"]

  number_of_custom_role_policy_arns = 1
}

# Github OIDC provider
module "github-oidc" {
  count  = (local.account_data.account-type == "member" && terraform.workspace != "testing-test") ? 1 : 0
  source = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=82f546bd5f002674138a2ccdade7d7618c6758b3" # v3.0.0
  providers = {
    aws = aws.workspace
  }
  additional_permissions = data.aws_iam_policy_document.oidc_assume_role_member[0].json
  github_repositories    = ["ministryofjustice/modernisation-platform-environments:*"]
  tags_common            = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix            = ""
}

data "aws_iam_policy_document" "oidc_assume_role_member" {
  count = local.account_data.account-type == "member" && terraform.workspace != "testing-test" ? 1 : 0
  statement {
    sid    = "AllowOIDCToAssumeRoles"
    effect = "Allow"
    resources = [
      format("arn:aws:iam::%s:role/member-delegation-%s-%s", local.environment_management.account_ids[format("core-vpc-%s", local.application_environment)], lower(local.business_unit), local.application_environment),
      format("arn:aws:iam::%s:role/modify-dns-records", local.environment_management.account_ids["core-network-services-production"]),
      format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id),
      format("arn:aws:iam::%s:role/modernisation-account-terraform-state-member-access", local.environment_management.modernisation_platform_account_id),
      # the two below are required as sprinkler and cooker have development accounts but are in the sandbox vpc
      local.application_name == "sprinkler" ? format("arn:aws:iam::%s:role/member-delegation-garden-sandbox", local.environment_management.account_ids["core-vpc-sandbox"]) : format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id),
      local.application_name == "cooker" ? format("arn:aws:iam::%s:role/member-delegation-house-sandbox", local.environment_management.account_ids["core-vpc-sandbox"]) : format("arn:aws:iam::%s:role/modernisation-account-limited-read-member-access", local.environment_management.modernisation_platform_account_id)
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.root_account.id]
    }
    actions = ["sts:AssumeRole"]
  }

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
    actions = ["s3:Get*",
    "s3:List*"]
  }

  statement {
    sid       = "AllowOIDCWriteState"
    effect    = "Allow"
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/*"]
    actions = ["s3:PutObject",
    "s3:PutObjectAcl"]
  }
}
