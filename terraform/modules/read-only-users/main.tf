# You can define readonly usernames, and their keybase key if applicable, below, and this will automatically create:
# - their account
# - an attachment to the "readonly" group, which has the IAM policy of readonly and can assume readonly roles, and forced MFA
# - if a keybase key is provided, it will also create their user login profile
locals {
  readonly_users = {
    "mikey.dunwoody" = "",
    "brett.thomas"   = "",
    "anton.preece"   = "",
    "stefan.thomas"  = ""
  }
}

# sleep to allow time for user creation
resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.iam_user]

  create_duration = "30s"

  triggers = {
    for user in module.iam_user : user.this_iam_user_name => user.this_iam_user_arn
  }

}

# Attach created users to a AWS IAM group, with several policies
module "iam_group_readonly_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.8"
  name    = "readonly"

  group_users = [
    for user in module.iam_user : user.this_iam_user_name
  ]

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    data.aws_iam_policy.ForceMFA.arn
  ]

  custom_group_policies = [
    {
      name   = "AssumeReadOnlyRole"
      policy = data.aws_iam_policy_document.assume_role.json
    }
  ]
}

# Create each user
module "iam_user" {
  for_each              = local.readonly_users
  source                = "terraform-aws-modules/iam/aws//modules/iam-user"
  version               = "~> 2.0"
  name                  = "${each.key}-readonly"
  force_destroy         = true
  pgp_key               = each.value
  create_iam_access_key = false

  # The following is dependent on whether a PGP key has been set
  create_iam_user_login_profile = length(each.value) > 0 ? true : false
  password_reset_required       = length(each.value) < 0 ? true : false
}

# Allow users to assume roles if MFA enabled
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["arn:aws:iam::*:role/readonly"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

data "aws_iam_policy" "ForceMFA" {
  name = "ForceMFA"
}
