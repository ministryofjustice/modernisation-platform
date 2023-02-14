resource "aws_iam_user" "s3_user" {
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
    resources = ["${module.s3_bucket[0].bucket.arn}"]
  }
}

resource "aws_iam_access_key" "s3_user" {
  user = aws_iam_user.s3_user.name
}

resource "aws_ssm_parameter" "s3_user" {
  name        = "/s3_user_access_key"
  description = "Access key for the S3 user"
  type        = "SecureString"
  value       = aws_iam_access_key.s3_user.encrypted_secret
}
