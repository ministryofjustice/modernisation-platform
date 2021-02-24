module "iam" {
  source        = "github.com/ministryofjustice/modernisation-platform-terraform-iam-superadmins?ref=v1.0.1"
  account_alias = "moj-modernisation-platform"
}

# CI User
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
