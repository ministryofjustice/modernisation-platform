module "s3_bucket_session_manager_logs" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=66bd5c6aa0d0396442f0d4a63642029ff38d2a8a" # v11.1.0

  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }

  bucket_policy               = [data.aws_iam_policy_document.session_manager_logs_bucket_policy.json]
  bucket_name                 = "modernisation-platform-logs-session-manager"
  suffix_name                 = "-session-manager"
  custom_kms_key              = aws_kms_key.session_manager_logs.arn
  sse_algorithm               = "aws:kms"
  enforce_kms_request_headers = false
  replication_enabled         = false
  versioning_enabled          = true

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      prefix  = ""
      tags    = {}
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 365
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 730
      }
      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 365
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]

  tags = local.tags
}

data "aws_iam_policy_document" "session_manager_logs_bucket_policy" {
  statement {
    sid    = "AllowFirehosePutObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose_to_s3_session_manager.arn]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${module.s3_bucket_session_manager_logs.bucket.arn}/*"
    ]
  }

  statement {
    sid    = "AllowFirehoseGetBucketAcl"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose_to_s3_session_manager.arn]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.s3_bucket_session_manager_logs.bucket.arn]
  }

  statement {
    sid    = "AllowOrgListBucket"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:ListBucket"]
    resources = [module.s3_bucket_session_manager_logs.bucket.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }
}
