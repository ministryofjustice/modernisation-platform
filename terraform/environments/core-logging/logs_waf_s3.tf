# S3 bucket for centralised modernisation platform waf logs
module "s3-bucket-modernisation-platform-waf-logs" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }

  bucket_name                = "modernisation-platform-waf-logs"
  replication_bucket         = "modernisation-platform-waf-logs-replication"
  suffix_name                = "-waf-logs"
  custom_kms_key             = aws_kms_key.s3_modernisation_platform_waf_logs.arn
  custom_replication_kms_key = aws_kms_key.s3_modernisation_platform_waf_logs_eu_west_1_replication.arn

  replication_enabled = true
  replication_region  = "eu-west-1"
  versioning_enabled  = true

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

  bucket_policy = [data.aws_iam_policy_document.modernisation_platform_waf_logs_bucket_policy.json]
}

data "aws_iam_policy_document" "modernisation_platform_waf_logs_bucket_policy" {
  # Allow only Kinesis Firehose from any MP Org account to put objects
  statement {
    sid       = "AllowOrgFirehosePut"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-modernisation-platform-waf-logs.bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }

  # Deny unencrypted object uploads
  statement {
    sid       = "DenyUnencryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-modernisation-platform-waf-logs.bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  # Allow AWS Config to list bucket objects from any MP Org account
  statement {
    sid       = "AllowOrgListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.s3-bucket-modernisation-platform-waf-logs.bucket.arn]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }
}
