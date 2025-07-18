#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-enforce-mfa
module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins?ref=83b376fb80315304f0a09287ff0ec9a358901591" # v3.0.0
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
  version = "~> 6.0"
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
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:mod-platform-circleci-??????",
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:nonmp-account-ids-??????",
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

# OIDC Provider for GitHub Actions Plan
#trivy:ignore:AVD-AWS-0345: Required for GitHub Actions to access Terraform state in S3
module "github_actions_plan_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
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

# OIDC Provider for GitHub Actions Apply
#trivy:ignore:AVD-AWS-0345: Required for GitHub Actions to access Terraform state in S3
module "github_actions_apply_role" {
  source              = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = ["ministryofjustice/modernisation-platform", "ministryofjustice/modernisation-platform-ami-builds", "ministryofjustice/modernisation-platform-security"]
  role_name           = "github-actions-apply"
  policy_arns         = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  policy_jsons        = [data.aws_iam_policy_document.oidc-deny-specific-actions.json]
  subject_claim       = "ref:refs/heads/main"
  tags                = { "Name" = "GitHub Actions Apply" }
}

# OIDC resources

module "github-oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=5dc9bc211d10c58de4247fa751c318a3985fc87b" # v4.0.0
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

# OIDC Provider for GitHub Actions Secrets Reader
#trivy:ignore:AVD-AWS-0345: 
module "github_actions_read_secrets_role" {
  source = "github.com/ministryofjustice/modernisation-platform-github-oidc-role?ref=b40748ec162b446f8f8d282f767a85b6501fd192" # v4.0.0
  github_repositories = [
    "ministryofjustice/modernisation-platform",
    "ministryofjustice/modernisation-platform-environments",
    "ministryofjustice/modernisation-platform-terraform-baselines",
    "ministryofjustice/modernisation-platform-ami-builds",
    "ministryofjustice/modernisation-platform-terraform-bastion-linux",
    "ministryofjustice/modernisation-platform-terraform-s3-bucket",
    "ministryofjustice/modernisation-platform-terraform-aws-vm-import",
    "ministryofjustice/modernisation-platform-terraform-ec2-instance",
    "ministryofjustice/modernisation-platform-terraform-pagerduty-integration",
    "ministryofjustice/modernisation-platform-terraform-iam-superadmins",
    "ministryofjustice/modernisation-platform-terraform-ec2-autoscaling-group",
    "ministryofjustice/modernisation-platform-terraform-member-vpc",
    "ministryofjustice/modernisation-platform-terraform-module-template",
    "ministryofjustice/modernisation-platform-github-oidc-role",
    "ministryofjustice/modernisation-platform-terraform-environments",
    "ministryofjustice/modernisation-platform-terraform-ecs-cluster",
    "ministryofjustice/modernisation-platform-github-oidc-provider",
    "ministryofjustice/modernisation-platform-terraform-ssm-patching",
    "ministryofjustice/modernisation-platform-terraform-aws-chatbot",
    "ministryofjustice/modernisation-platform-terraform-lambda-function",
    "ministryofjustice/modernisation-platform-terraform-dns-certificates",
    "ministryofjustice/modernisation-platform-instance-scheduler",
    "ministryofjustice/modernisation-platform-terraform-loadbalancer",
    "ministryofjustice/modernisation-platform-terraform-aws-data-firehose",
    "ministryofjustice/modernisation-platform-terraform-cross-account-access",
    "ministryofjustice/modernisation-platform-security"
  ]
  role_name    = "github-actions-read-secrets"
  policy_jsons = [data.aws_iam_policy_document.oidc_assume_read_secrets_role_member.json]
  tags         = { "Name" = "GitHub Actions Read Secrets" }
}

data "aws_iam_policy_document" "oidc_assume_read_secrets_role_member" {
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
