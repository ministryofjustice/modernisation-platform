#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-enforce-mfa
module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins?ref=bea5d084de2f810eee5326562ad6d9d104a2aa05" # v2.0.7
  account_alias = "moj-modernisation-platform"
}

### Collaborators

# Attach created users to a AWS IAM group, with several policies
#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-enforce-mfa
module "collaborators_group" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  #checkov:skip=CKV_TF_2:Module registry does not support tags
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 5.0"
  name    = "collaborators"

  group_users = [for user in module.collaborators : user.username]

  custom_group_policy_arns = [
    data.aws_iam_policy.ForceMFA.arn,
    aws_iam_policy.collaborator_local_plan.arn,
    aws_iam_policy.modernisation_account_limited_read.arn
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
      "arn:aws:s3:::modernisation-platform-terraform-state/*.tflock",
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
    sid     = "TerraformStateAccessDeleteLock"
    actions = ["s3:DeleteObject"]

    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/*.tflock"]

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
  statement {
    sid    = "ViewConsoleHome"
    effect = "Allow"
    actions = [
      "ec2:DescribeRegions",
      "notifications:ListNotificationHubs",
      "health:DescribeEventAggregates",
      "cost-optimization-hub:ListEnrollmentStatuses",
      "ce:GetCostAndUsage"
    ]
    resources = ["*"]
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
    sid       = "AllowS3AccessList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
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
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/members/*",
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/bootstrap/*"
    ]
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

# OIDC Provider for GitHub Actions Plan

module "github_actions_plan_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=62b8a16c73d8e4422cd81923e46948e8f4b5cf48" # v3.2.0
  github_repositories = ["ministryofjustice/modernisation-platform", "ministryofjustice/modernisation-platform-ami-builds", "ministryofjustice/modernisation-platform-security"]
  role_name           = "github-actions-plan"
  policy_jsons        = [data.aws_iam_policy_document.oidc_assume_plan_role_member.json]
  tags                = { "Name" = "GitHub Actions Plan" }
}

data "aws_iam_policy_document" "oidc_assume_plan_role_member" {
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
    sid    = "AssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${local.environment_management.account_ids["core-logging-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-development"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-preproduction"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-sandbox"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-security-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.aws_organizations_root_account_id}:role/ModernisationPlatformSSOAdministrator"
    ]
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

# OIDC Provider for GitHub Actions Apply

module "github_actions_apply_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=62b8a16c73d8e4422cd81923e46948e8f4b5cf48" # v3.2.0
  github_repositories = ["ministryofjustice/modernisation-platform", "ministryofjustice/modernisation-platform-ami-builds", "ministryofjustice/modernisation-platform-security"]
  role_name           = "github-actions-apply"
  policy_arns         = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  policy_jsons        = [data.aws_iam_policy_document.oidc-deny-specific-actions.json]
  subject_claim       = "ref:refs/heads/main"
  tags                = { "Name" = "GitHub Actions Apply" }
}

# OIDC resources

module "github-oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=82f546bd5f002674138a2ccdade7d7618c6758b3" # v3.0.0
  additional_permissions      = data.aws_iam_policy_document.oidc-deny-specific-actions.json
  additional_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  github_repositories         = ["ministryofjustice/modernisation-platform:*", "ministryofjustice/modernisation-platform-ami-builds:*", "ministryofjustice/modernisation-platform-security:*"]
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
