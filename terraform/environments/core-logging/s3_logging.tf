data "aws_organizations_organization" "moj_root_account" {}


# If you need to rebuild aws_kms_key resource, you need to comment out line 9 below due to a circular dep on the first run.

# KMS Source
resource "aws_kms_key" "s3_logging_cloudtrail" {
  description             = "s3-logging-cloudtrail"
  policy                  = data.aws_iam_policy_document.kms_logging_cloudtrail.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
}
resource "aws_kms_alias" "s3_logging_cloudtrail" {
  name          = "alias/s3-logging-cloudtrail"
  target_key_id = aws_kms_key.s3_logging_cloudtrail.id
}
data "aws_iam_policy_document" "kms_logging_cloudtrail" {

  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"

  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Enable decrypt access to accounts within the organisation"
    effect = "Allow"
    actions = [
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values = [
        data.aws_organizations_organization.moj_root_account.id
      ]
    }
  }
  statement {
    sid    = "Allow use of the key including encryption"
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt*",
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
  statement {
    sid    = "Allow use of the key by SQS"
    effect = "Allow"
    actions = [
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = [aws_sqs_queue.mp_cloudtrail_log_queue.arn]
    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }
  }

  statement {
    sid    = "Allow key decryption to STS bucket replication roles"
    effect = "Allow"
    actions = [
      "kms:Decrypt*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail/s3-replication",
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail-logging/s3-replication",
      ]
    }
  }
}


# KMS Destination
resource "aws_kms_key" "s3_logging_cloudtrail_eu-west-1_replication" {
  provider = aws.modernisation-platform-eu-west-1

  description             = "s3-logging-cloudtrail-eu-west-1-replication"
  policy                  = data.aws_iam_policy_document.kms_logging_cloudtrail_replication.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = { Name = "${local.application_name}-s3-logging-cloudtrail-kms" }
}
resource "aws_kms_alias" "s3_logging_cloudtrail_eu-west-1_replication" {
  provider = aws.modernisation-platform-eu-west-1

  name          = "alias/s3-logging-cloudtrail-eu-west-1-replication"
  target_key_id = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.id
}
data "aws_iam_policy_document" "kms_logging_cloudtrail_replication" {

  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "role is resticted by limited actions in member account"

  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Allow key decryption to STS bucket replication roles"
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:Encrypt*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail/s3-replication",
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSS3BucketReplication-cloudtrail-logging/s3-replication",
      ]
    }
  }
}


module "s3-bucket-cloudtrail" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=474f27a3f9bf542a8826c76fb049cc84b5cf136f" # v8.2.1
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy              = [data.aws_iam_policy_document.cloudtrail_bucket_policy.json]
  bucket_name                = "modernisation-platform-logs-cloudtrail"
  replication_bucket         = "modernisation-platform-logs-cloudtrail-replication"
  suffix_name                = "-cloudtrail"
  custom_kms_key             = aws_kms_key.s3_logging_cloudtrail.arn
  custom_replication_kms_key = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.arn

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
  log_bucket = module.s3-bucket-cloudtrail-logging.bucket.id
  log_buckets = tomap({
    "log_bucket_name" : module.s3-bucket-cloudtrail-logging.bucket.id,
    "log_bucket_arn" : module.s3-bucket-cloudtrail-logging.bucket.arn,
    "log_bucket_policy" : module.s3-bucket-cloudtrail-logging.bucket_policy.policy,
  })
  log_prefix = ""

  tags = local.tags
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
  statement {
    sid    = "allowReadListToLoggingAccount_1"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetBucketTagging",
      "s3:GetBucketLogging",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetBucketPolicy",
      "s3:GetEncryptionConfiguration",
      "s3:GetObjectTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion"
    ]
    resources = [
      module.s3-bucket-cloudtrail.bucket.arn,
      format("%s/*", module.s3-bucket-cloudtrail.bucket.arn)
    ]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

module "s3-bucket-cloudtrail-logging" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=474f27a3f9bf542a8826c76fb049cc84b5cf136f" # v8.2.1
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }

  acl                        = "log-delivery-write"
  bucket_name                = "modernisation-platform-logs-cloudtrail-logging"
  replication_bucket         = "modernisation-platform-logs-cloudtrail-logging-replication"
  suffix_name                = "-cloudtrail-logging"
  custom_kms_key             = aws_kms_key.s3_logging_cloudtrail.arn
  custom_replication_kms_key = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.arn

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


data "aws_organizations_organization" "current" {}

# Source KMS Key
resource "aws_kms_key" "s3_logging_shield_advanced" {
  description             = "KMS key for Shield Advanced logging bucket"
  policy                  = data.aws_iam_policy_document.kms_logging_shield_advanced.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "s3_logging_shield_advanced" {
  name          = "alias/s3-logging-shield-advanced"
  target_key_id = aws_kms_key.s3_logging_shield_advanced.id
}

data "aws_iam_policy_document" "kms_logging_shield_advanced" {
  # Allow full admin access to the KMS key for Modernisation Platform
  statement {
    sid       = "AllowKeyAdmin"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  # Allow Kinesis Firehose to encrypt logs
  statement {
    sid    = "AllowFirehoseEncrypt"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }

  # Allow XSIAM Cortex role to decrypt
  statement {
    sid    = "AllowCortexXsiamDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cortex_xsiam_role.arn]
    }
  }

  # Allow SQS to decrypt
  statement {
    sid    = "AllowSQSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }
  }

  # Allow S3 replication role to use the key
  statement {
    sid    = "AllowS3Replication"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSS3BucketReplication-shield-advanced/s3-replication"
      ]
    }
  }
}

# Destination KMS Key
resource "aws_kms_key" "s3_logging_shield_advanced_eu_west_1_replication" {
  provider                = aws.modernisation-platform-eu-west-1
  description             = "KMS key for Shield Advanced logging bucket replication (eu-west-1)"
  policy                  = data.aws_iam_policy_document.kms_logging_shield_advanced_replication.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "s3_logging_shield_advanced_eu_west_1_replication" {
  provider      = aws.modernisation-platform-eu-west-1
  name          = "alias/s3-logging-shield-advanced-eu-west-1-replication"
  target_key_id = aws_kms_key.s3_logging_shield_advanced_eu_west_1_replication.id
}

data "aws_iam_policy_document" "kms_logging_shield_advanced_replication" {
  #Allow full admin access to the KMS key for Mod Platform
  statement {
    sid       = "AllowKeyAdmin"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  # Allow S3 replication role to use the key
  statement {
    sid    = "AllowS3Replication"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSS3BucketReplication-shield-advanced/s3-replication"
      ]
    }
  }
}

# S3 bucket for Shield Advanced logging (WAF logs)
module "s3-bucket-shield-advanced-logging" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=474f27a3f9bf542a8826c76fb049cc84b5cf136f" # v8.2.1
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }

  bucket_name                = "modernisation-platform-logs-shield-advanced-logging"
  replication_bucket         = "modernisation-platform-logs-shield-advanced-logging-replication"
  suffix_name                = "-cloudtrail-logging"
  custom_kms_key             = aws_kms_key.s3_logging_shield_advanced.arn
  custom_replication_kms_key = aws_kms_key.s3_logging_shield_advanced_eu_west_1_replication.arn

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

  bucket_policy = [data.aws_iam_policy_document.shield_advanced_bucket_policy.json]
}

data "aws_iam_policy_document" "shield_advanced_bucket_policy" {
  # Allow only Kinesis Firehose from any MP Org account to put objects
  statement {
    sid       = "AllowOrgFirehosePut"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-shield-advanced-logging.bucket.arn}/*"]
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
    resources = ["${module.s3-bucket-shield-advanced-logging.bucket.arn}/*"]
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
}