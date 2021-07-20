resource "aws_kms_key" "s3_logging_cloudtrail" {
  description             = "s3-logging-cloudtrail"
  policy                  = data.aws_iam_policy_document.kms_logging_cloudtrail.json
  deletion_window_in_days = 30
}
resource "aws_kms_alias" "s3_logging_cloudtrail" {
  name          = "alias/s3-logging-cloudtrail"
  target_key_id = aws_kms_key.s3_logging_cloudtrail.id
}
data "aws_iam_policy_document" "kms_logging_cloudtrail" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_caller_identity.current.account_id}"]
    }
  }
  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = ["kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt*",
      "kms:Describe*",
    "kms:Decrypt*"]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}
module "s3-bucket-cloudtrail" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v3.0.0"
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy       = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
  bucket_name         = "modernisation-platform-logs-cloudtrail"
  replication_enabled = true
  lifecycle_rule = [
    {
      id      = "main"
      enabled = true
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
  replication_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSS3BucketReplication"
  tags                 = local.tags
}
# Allow access to the bucket from the MoJ root account
# Policy extrapolated from:
# https://www.terraform.io/docs/backends/types/s3.html#s3-bucket-permissions
data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid       = "AllowListBucketACL"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [module.s3-bucket-cloudtrail.bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
  statement {
    sid       = "AllowOnlyEncryptedObjects"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-cloudtrail.bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }
  statement {
    sid       = "DenyUnencryptedData"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-cloudtrail.bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}