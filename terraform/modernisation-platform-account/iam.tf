#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-enforce-mfa
module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins?ref=v1.0.14"
  account_alias = "moj-modernisation-platform"
}

# Core CI User
# IAM policy that denies:
# - changing IAM passwords for anyone
# - creating console login profiles
# - creating access keys for anyone apart from itself
# - deleting IAM users
# - deleting virtual MFA devices
data "aws_iam_policy_document" "deny-specific-actions" {
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

  statement {
    effect = "Deny"
    actions = [
      "iam:CreateAccessKey"
    ]
    resources = ["arn:aws:iam::*:user/$${aws:username}"]
  }
}

resource "aws_iam_policy" "deny-specific-actions" {
  name        = "DenyLockoutActions"
  description = "Denies several permissions required to lock other people out of their accounts, such as deleting a user or their MFA device"
  policy      = data.aws_iam_policy_document.deny-specific-actions.json
}

# Member CI User

# Member CI policy
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "member-ci-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::*:role/MemberInfrastructureAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-development"]}:role/member-delegation-*-development",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/member-delegation-*-test",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-preproduction"]}:role/member-delegation-*-preproduction",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-production"]}:role/member-delegation-*-production",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-sandbox"]}:role/member-delegation-*-sandbox",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/modify-dns-records"
    ]
  }

  statement {
    effect  = "Deny"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-development"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-preproduction"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-sandbox-dev"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-logging-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/ModernisationPlatformAccess"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::modernisation-platform-terraform-state/environments/*",
      "arn:aws:s3:::modernisation-platform-terraform-state/terraform.tfstate"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::modernisation-platform-terraform-state/environments/members/*"]
  }

  # Based on https://www.terraform.io/docs/language/settings/backends/s3.html#dynamodb-table-permissions
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.state-lock.arn]
  }

  # Based on https://docs.amazonaws.cn/en_us/AmazonS3/latest/userguide/UsingKMSEncryption.htm
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      aws_kms_key.dynamo_encryption.arn,
      aws_kms_key.s3_state_bucket.arn
    ]
  }

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
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:nuke_account_blocklist-??????",
      "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:nuke_account_ids-??????"
    ]
  }
}

resource "aws_iam_policy" "member-ci-policy" {
  name        = "MemberCiAllowActions"
  description = "Allowed actions for the member-ci Group"
  policy      = data.aws_iam_policy_document.member-ci-policy.json
}

# Create a member CI group to attach the policy to
#tfsec:ignore:aws-iam-enforce-mfa
resource "aws_iam_group" "member-ci" {
  name = "member-ci"
}

# Attach DenyLockoutActions to the group
resource "aws_iam_group_policy_attachment" "member-ci-deny-specific-actions" {
  group      = aws_iam_group.member-ci.id
  policy_arn = aws_iam_policy.deny-specific-actions.id
}

# Attach Member CI Policy to the group
resource "aws_iam_group_policy_attachment" "member-ci-policy" {
  group      = aws_iam_group.member-ci.id
  policy_arn = aws_iam_policy.member-ci-policy.id
}

# Create a member CI user
resource "aws_iam_user" "member-ci" {
  name = "member-ci"
  tags = local.tags
}

# Add the member CI user to the CI group
resource "aws_iam_user_group_membership" "member-ci" {
  user = aws_iam_user.member-ci.name
  groups = [
    aws_iam_group.member-ci.name
  ]
}

# Create access keys for the CI user
# NOTE: These are extremely sensitive keys. Do not output these anywhere publicly accessible.
resource "aws_iam_access_key" "member-ci" {
  user = aws_iam_user.member-ci.name

  # Setting the meta lifecycle argument allows us to periodically run `terraform taint aws_iam_access_key.ci`, and run
  # terraform apply to create new keys before these ones are destroyed.
  lifecycle {
    create_before_destroy = true
  }
}

### Collaborators

# Attach created users to a AWS IAM group, with several policies
#tfsec:ignore:aws-iam-no-policy-wildcards
#tfsec:ignore:aws-iam-enforce-mfa
module "collaborators_group" {
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
      "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/read-dns-records",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-development"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-preproduction"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-production"]}:role/member-delegation-read-only",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-sandbox"]}:role/member-delegation-read-only",
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

# OIDC resources

module "github-oidc" {
  source                      = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=v2.0.0"
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