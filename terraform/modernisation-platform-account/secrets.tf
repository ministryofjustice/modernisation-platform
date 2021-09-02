# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

# Define keys iam policy used by ci_iam_user_key and member_ci_iam_user_key below
data "aws_iam_policy_document" "ci_iam_user_keys_policy" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = local.root_users_with_state_access
    }

    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}

# Core CI User
resource "aws_kms_key" "ci_iam_user_keys_key" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.ci_iam_user_keys_policy.json
}


resource "aws_secretsmanager_secret" "ci_iam_user_keys" {
  name        = "ci_iam_user_keys"
  description = "Access keys for the CI user, this secret is used by GitHub to set the correct repository secrets."
  tags        = local.tags
  kms_key_id  = aws_kms_key.ci_iam_user_keys_key.arn
}

resource "aws_secretsmanager_secret_version" "ci_iam_user_keys" {
  secret_id = aws_secretsmanager_secret.ci_iam_user_keys.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.ci.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.ci.secret
  })
}

# Member CI user
resource "aws_kms_key" "member_ci_iam_user_keys_key" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.ci_iam_user_keys_policy.json
}

resource "aws_secretsmanager_secret" "member_ci_iam_user_keys" {
  name        = "member_ci_iam_user_keys"
  description = "Access keys for the CI user, this secret is used by GitHub to set the correct repository secrets."
  tags        = local.tags
  kms_key_id  = aws_kms_key.member_ci_iam_user_keys_key.arn
}

resource "aws_secretsmanager_secret_version" "member_ci_iam_user_keys" {
  secret_id = aws_secretsmanager_secret.member_ci_iam_user_keys.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.member-ci.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.member-ci.secret
  })
}
