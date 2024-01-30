#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "s3_user" {
  # checkov:skip=CKV_AWS_273:"SSO not used as this is used by an app to authenticate"
  name = format("%s-%s-s3_user", local.application_name, local.environment)
  tags = merge(local.tags,
    { Name = format("%s-%s-s3_user", local.application_name, local.environment) }
  )
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name   = "s3_user_policy"
  user   = aws_iam_user.s3_user.name
  policy = data.aws_iam_policy_document.s3_user.json
}

data "aws_iam_policy_document" "s3_user" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::${local.application_name}-${local.environment}*"]
  }
}

resource "aws_iam_access_key" "s3_user" {
  user = aws_iam_user.s3_user.name
}

resource "aws_secretsmanager_secret" "s3_user_access_key" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not currently possible
  kms_key_id              = data.aws_kms_key.general_shared.arn
  name                    = "${local.application_name}-s3-user-access-key"
  recovery_window_in_days = 0
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-s3-user-access-key"
    }
  )
}

resource "aws_secretsmanager_secret_version" "s3_user_access_key" {
  secret_id     = aws_secretsmanager_secret.s3_user_access_key.id
  secret_string = aws_iam_access_key.s3_user.id
}

resource "aws_secretsmanager_secret" "s3_user_secret_key" {
  # checkov:skip=CKV2_AWS_57:Auto rotation not currently possible
  kms_key_id              = data.aws_kms_key.general_shared.arn
  name                    = "${local.application_name}-s3-user-secret-key"
  recovery_window_in_days = 0
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-s3-user-secret-key"
    }
  )
}

resource "aws_secretsmanager_secret_version" "s3_user_secret_key" {
  secret_id     = aws_secretsmanager_secret.s3_user_secret_key.id
  secret_string = aws_iam_access_key.s3_user.secret
}