## S3 Bucket Module for AWS Route 53 Public DNS Query Logs
module "s3_bucket_r53_public_dns_logs" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0

  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy              = [data.aws_iam_policy_document.r53_public_dns_logs_bucket_policy.json]
  bucket_name                = "modernisation-platform-logs-r53-public-dns-logs"
  replication_bucket         = "modernisation-platform-logs-r53-public-dns-logs-replication"
  suffix_name                = "-r53-public-dns-logs"
  custom_kms_key             = aws_kms_key.r53_public_dns_logs.arn
  custom_replication_kms_key = aws_kms_key.r53_public_dns_logs_replication.arn
  replication_enabled        = true
  replication_region         = "eu-west-1"
  versioning_enabled         = true

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
          }, {
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
          }, {
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

data "aws_iam_policy_document" "r53_public_dns_logs_bucket_policy" {
  statement {
    sid       = "AllowFirehosePut"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::modernisation-platform-logs-r53-public-dns-logs/*"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.environment_management.account_ids["core-network-services-production"]]
    }
  }

  statement {
    sid       = "DenyUnencryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::modernisation-platform-logs-r53-public-dns-logs/*"]
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

  statement {
    sid       = "AllowListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::modernisation-platform-logs-r53-public-dns-logs"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.environment_management.account_ids["core-network-services-production"]]
    }
  }
}
