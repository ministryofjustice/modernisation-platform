data "aws_s3_bucket" "r2s" {
  bucket = "r2s-resources-421101632357-eu-west-2"
}

resource "aws_iam_role" "r2s_s3_readonly" {
  name = "r2s-s3-readonly"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.environment_management.modernisation_platform_account_id}:root"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
          NumericLessThan = {
            "aws:MultiFactorAuthAge" = "86400"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "r2s_s3_readonly" {
  role       = aws_iam_role.r2s_s3_readonly.name
  policy_arn = aws_iam_policy.r2s_s3_readonly.arn
}

resource "aws_iam_policy" "r2s_s3_readonly" {
  name        = "r2s-s3-readonly"
  description = "Allow listing and reading objects from a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = data.aws_s3_bucket.r2s.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${data.aws_s3_bucket.r2s.arn}/*"
      }
    ]
  })
}