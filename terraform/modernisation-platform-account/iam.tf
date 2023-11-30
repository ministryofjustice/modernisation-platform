#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-enforce-mfa
module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins?ref=2390874e4b8f1d01fd21c342d253345ec8a5b708" # v2.0.0
  account_alias = "moj-modernisation-platform"
}

### Collaborators

# Attach created users to a AWS IAM group, with several policies
#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-enforce-mfa
module "collaborators_group" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 5.0"
  name    = "collaborators"

  group_users = [for user in module.collaborators : user.username]

  custom_group_policy_arns = [
    data.aws_iam_policy.ForceMFA.arn,
    aws_iam_policy.collaborator_local_plan.arn
  ]
}

data "aws_iam_policy" "ForceMFA" {
  name = "ForceMFA"
}

resource "aws_iam_policy" "collaborator_local_plan" {
  name        = "collaborator-local-plan"
  description = "Permissions collaborators need to perform local Terraform plans"
  policy      = data.aws_iam_policy_document.collaborator_local_plan.json
}

data "aws_iam_policy_document" "collaborator_local_plan" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/read-log-records",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-development"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-preproduction"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-production"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-sandbox"]}:role/member-delegation-read-only",
      "arn:aws:iam::${data.aws_caller_identity.current.id}:role/modernisation-account-limited-read-member-access"
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    sid = "TerraformStateAccess"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/terraform.tfstate",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/members/*",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/accounts/core-network-services/*",
      "arn:aws:s3:::modernisation-platform-terraform-state"
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }

  statement {
    sid    = "ssmAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.id}:parameter/modernisation_platform_account_id"
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

#tfsec:ignore:aws-iam-no-user-attached-policies
module "collaborators" {
  source                 = "../modules/collaborators"
  for_each               = { for user in local.collaborators.users : user.username => user.accounts }
  username               = each.key
  accounts               = each.value
  environment_management = local.environment_management
}

# Modernisation Platform Account Readonly Role
data "aws_iam_policy_document" "modernisation_account_limited_read_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

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

resource "aws_iam_role" "modernisation_account_limited_read" {
  name                 = "modernisation-account-limited-read-member-access"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.modernisation_account_limited_read_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "modernisation_account_limited_read" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:environment_management-??????",
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:pagerduty_integration_keys-??????",
    ]
  }
  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::*"]
  }
}
resource "aws_iam_policy" "modernisation_account_limited_read" {
  name        = "ModernisationAccountLimitedRead"
  description = "Limited Read Access in MP Account for Members and CI"
  policy      = data.aws_iam_policy_document.modernisation_account_limited_read.json
}

resource "aws_iam_role_policy_attachment" "modernisation_account_limited_read" {
  role       = aws_iam_role.modernisation_account_limited_read.id
  policy_arn = aws_iam_policy.modernisation_account_limited_read.arn
}

# Modernisation Platform Environments Terraform backend role

data "aws_iam_policy_document" "modernisation_account_terraform_state_role" {
  version = "2012-10-17"
  statement {
    sid    = "AllowDynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/modernisation-platform-terraform-state-lock"]
  }
  statement {
    sid    = "AllowS3AccessList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state"]
  }
  statement {
    sid    = "AllowS3AccessActions"
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/*"]
  }
}

data "aws_iam_policy_document" "modernisation_account_terraform_state_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

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

resource "aws_iam_role" "modernisation_account_terraform_state" {
  name                 = "modernisation-account-terraform-state-member-access"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.modernisation_account_terraform_state_assume_role.json

  tags = local.tags
}

resource "aws_iam_policy" "modernisation_account_terraform_state" {
  name        = "ModernisationAccountTerraformState"
  description = "Role allowing Modernisation Platform customers access to Terraform state backend resources"
  policy      = data.aws_iam_policy_document.modernisation_account_terraform_state_role.json
}

resource "aws_iam_role_policy_attachment" "modernisation_account_terraform_state" {
  role       = aws_iam_role.modernisation_account_terraform_state.id
  policy_arn = aws_iam_policy.modernisation_account_terraform_state.arn
}


# OIDC resources

module "github-oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=82f546bd5f002674138a2ccdade7d7618c6758b3" # v3.0.0
  additional_permissions      = data.aws_iam_policy_document.oidc-deny-specific-actions.json
  additional_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  github_repositories         = ["ministryofjustice/modernisation-platform:*", "ministryofjustice/modernisation-platform-ami-builds:*"]
  tags_common                 = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix                 = ""
}

data "aws_iam_policy_document" "oidc-deny-specific-actions" {
  statement {
    effect = "Deny"
    actions = [
      "iam:ChangePassword",
      "iam:CreateLoginProfile",
      "iam:DeleteUser",
      "iam:DeleteVirtualMFADevice"
    ]
    resources = ["*"]
  }
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "sso_customer_managed_policy_engineer" {
  #checkov:skip=CKV_AWS_356: Allows access to multiple unknown resources
  statement {
    sid       = "SSOCustomerManagedPolicyEngineer"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ec2:CreateTags"]
  }
}

resource "aws_iam_policy" "sso_customer_managed_policy_engineer" {

  name        = "SSOCustomerManagedPolicyEngineer"
  path        = "/"
  description = "Restricted policy for use for the testing of customer managed SSO policies"
  policy      = data.aws_iam_policy_document.sso_customer_managed_policy_engineer.json
}