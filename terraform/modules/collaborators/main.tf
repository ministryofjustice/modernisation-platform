# sleep to allow time for user creation
resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.iam_user]

  create_duration = "30s"

  triggers = {
    user = module.iam_user.iam_user_name
  }
}


# Create each user
module "iam_user" {
  # checkov:skip=CKV_TF_1:
  # checkov:skip=CKV_TF_2:
  source                        = "terraform-aws-modules/iam/aws//modules/iam-user"
  version                       = "~> 5.0"
  name                          = var.username
  force_destroy                 = true
  create_iam_user_login_profile = false
  create_iam_access_key         = false
}

resource "aws_iam_user_policy" "user_policy" {
  name   = "assume-roles-${var.username}"
  user   = module.iam_user.iam_user_name
  policy = data.aws_iam_policy_document.assume_role.json
}

# Allow users to assume roles if MFA enabled
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [for account in var.accounts :
      join("", [
        "arn:aws:iam::",
        var.environment_management.account_ids[account.account-name],
        ":role/",
        account.access
    ])]

    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}
