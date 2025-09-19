## S3 Bucket Module for AWS Config Logs
module "s3_bucket_config_logs" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0

  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy              = [data.aws_iam_policy_document.config_bucket_policy.json]
  bucket_name                = "modernisation-platform-logs-config"
  replication_bucket         = "modernisation-platform-logs-config-replication"
  suffix_name                = "-config"
  custom_kms_key             = aws_kms_key.config_logs.arn
  custom_replication_kms_key = aws_kms_key.config_logs_replication.arn
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

data "aws_iam_policy_document" "config_bucket_policy" {
  statement {
    sid    = "AllowAWSConfigPutObject"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${module.s3_bucket_config_logs.bucket.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [data.aws_organizations_organization.moj_root_account.id]
    }
  }

  statement {
    sid    = "AllowGetBucketAcl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [module.s3_bucket_config_logs.bucket.arn]
  }

  statement {
    sid    = "AllowAWSConfigListObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:ListBucket"]
    resources = [module.s3_bucket_config_logs.bucket.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.moj_root_account.id]
    }
  }
}
