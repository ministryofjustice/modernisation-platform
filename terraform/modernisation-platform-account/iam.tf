module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins?ref=v1.0.2"
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

# Create a CI group to attach the policy to
resource "aws_iam_group" "ci" {
  name = "ci"
}

# Attach AdministratorAccess to the group
resource "aws_iam_group_policy_attachment" "administrator-access" {
  group      = aws_iam_group.ci.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Attach DenyLockoutActions to the group
resource "aws_iam_group_policy_attachment" "deny-specific-actions" {
  group      = aws_iam_group.ci.id
  policy_arn = aws_iam_policy.deny-specific-actions.id
}

# Create a CI user
resource "aws_iam_user" "ci" {
  name = "ci"
  tags = local.tags
}

# Add the CI user to the CI group
resource "aws_iam_user_group_membership" "ci-ci" {
  user = aws_iam_user.ci.name
  groups = [
    aws_iam_group.ci.name
  ]
}

# Create access keys for the CI user
# NOTE: These are extremely sensitive keys. Do not output these anywhere publicly accessible.
resource "aws_iam_access_key" "ci" {
  user = aws_iam_user.ci.name

  # Setting the meta lifecycle argument allows us to periodically run `terraform taint aws_iam_access_key.ci`, and run
  # terraform apply to create new keys before these ones are destroyed.
  lifecycle {
    create_before_destroy = true
  }
}

# Member CI User

# Member CI policy
data "aws_iam_policy_document" "member-ci-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::*:role/ModernisationPlatformAccess",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-development"]}:role/member-delegation-*-development",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-test"]}:role/member-delegation-*-test",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-preproduction"]}:role/member-delegation-*-preproduction",
      "arn:aws:iam::${local.environment_management.account_ids["core-vpc-production"]}:role/member-delegation-*-production",
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

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets"
    ]
    resources = ["arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:environment_management-??????"]
  }
}

resource "aws_iam_policy" "member-ci-policy" {
  name        = "MemberCiAllowActions"
  description = "Allowed actions for the member-ci Group"
  policy      = data.aws_iam_policy_document.member-ci-policy.json
}

# Create a member CI group to attach the policy to
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
