data "aws_organizations_organization" "moj_root_account" {}

################################
# CloudTrail Logging S3 Bucket #
################################
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
      identifiers = ["logging.s3.amazonaws.com", "cloudtrail.amazonaws.com", "logs.amazonaws.com"]
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
    sid    = "Allow use of the key by the ModernisationPlatformAccess role in all MP accounts"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Encrypt*",
      "kms:Describe*",
      "kms:Decrypt*"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.moj_root_account.id]
    }
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/ModernisationPlatformAccess"]
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
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }
  bucket_policy              = [data.aws_iam_policy_document.cloudtrail_bucket_policy.json]
  bucket_name                = "modernisation-platform-logs-cloudtrail"
  replication_bucket         = "modernisation-platform-logs-cloudtrail-replication"
  suffix_name                = "-cloudtrail"
  custom_kms_key             = aws_kms_key.s3_logging_cloudtrail.arn
  custom_replication_kms_key = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.arn
  replication_enabled        = true
  replication_region         = "eu-west-1"
  ownership_controls         = "BucketOwnerEnforced"
  log_bucket                 = module.s3-bucket-cloudtrail-logging.bucket.id
  log_buckets = tomap({
    "log_bucket_name" : module.s3-bucket-cloudtrail-logging.bucket.id,
    "log_bucket_arn" : module.s3-bucket-cloudtrail-logging.bucket.arn,
    "log_bucket_policy" : module.s3-bucket-cloudtrail-logging.bucket_policy.policy,
  })
  log_prefix = ""
  tags       = local.tags
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid       = "AllowCloudTrailPutObjectAndGetBucketACLWithinOrg"
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetBucketAcl"]
    resources = ["${module.s3-bucket-cloudtrail.bucket.arn}/*", module.s3-bucket-cloudtrail.bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values   = [data.aws_organizations_organization.moj_root_account.id]
    }
  }
}

module "s3-bucket-cloudtrail-logging" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=9facf9fc8f8b8e3f93ffbda822028534b9a75399" # v9.0.0
  providers = {
    aws.bucket-replication = aws.modernisation-platform-eu-west-1
  }

  bucket_policy              = [data.aws_iam_policy_document.cloudtrail_logging_bucket_policy.json]
  bucket_name                = "modernisation-platform-logs-cloudtrail-logging"
  replication_bucket         = "modernisation-platform-logs-cloudtrail-logging-replication"
  suffix_name                = "-cloudtrail-logging"
  custom_kms_key             = aws_kms_key.s3_logging_cloudtrail.arn
  custom_replication_kms_key = aws_kms_key.s3_logging_cloudtrail_eu-west-1_replication.arn
  ownership_controls         = "BucketOwnerEnforced"

  replication_enabled = true
  replication_region  = "eu-west-1"

  tags = local.tags
}

data "aws_iam_policy_document" "cloudtrail_logging_bucket_policy" {
  statement {
    sid       = "AllowS3ServerAccessLoggingPutObjectFromSourceBucketWithinAccount"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${module.s3-bucket-cloudtrail-logging.bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.s3-bucket-cloudtrail.bucket.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

##########################
# WAF Logging S3 Bucket #
##########################
data "aws_organizations_organization" "current" {}
data "aws_region" "current" {}

# Source KMS Key
resource "aws_kms_key" "s3_modernisation_platform_waf_logs" {
  description             = "KMS key for modernisation platform waf logs bucket"
  policy                  = data.aws_iam_policy_document.kms_logging_modernisation_platform_waf_logs.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "s3_modernisation_platform_waf_logs" {
  name          = "alias/s3-modernisation-platform-waf-logs"
  target_key_id = aws_kms_key.s3_modernisation_platform_waf_logs.id
}

data "aws_iam_policy_document" "kms_logging_modernisation_platform_waf_logs" {
  # checkov:skip=CKV_AWS_109: "Policy is restricted to internal account and roles"
  # checkov:skip=CKV_AWS_111: "Write access allowed only for approved services"
  # checkov:skip=CKV_AWS_356: "Wildcard used in internal context and not public"

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

  statement {
    sid    = "AllowFirehoseAndLogsEncrypt"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
        "logs.${data.aws_region.current.region}.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }

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
        format(
          "arn:aws:sts::%s:assumed-role/AWSS3BucketReplication-waf-logs/s3-replication",
          data.aws_caller_identity.current.account_id
        )
      ]
    }
  }
}

# Destination KMS Key
resource "aws_kms_key" "s3_modernisation_platform_waf_logs_eu_west_1_replication" {
  provider                = aws.modernisation-platform-eu-west-1
  description             = "KMS key for modernisation platform waf logs bucket replication (eu-west-1)"
  policy                  = data.aws_iam_policy_document.kms_logging_modernisation_platform_waf_logs_replication.json
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = local.tags
}

resource "aws_kms_alias" "s3_logging_modernisation_platform_waf_logs_eu_west_1_replication" {
  provider      = aws.modernisation-platform-eu-west-1
  name          = "alias/s3-modernisation-platform-waf-logs-eu-west-1-replication"
  target_key_id = aws_kms_key.s3_modernisation_platform_waf_logs_eu_west_1_replication.id
}

data "aws_iam_policy_document" "kms_logging_modernisation_platform_waf_logs_replication" {
  # checkov:skip=CKV_AWS_109: "Policy is restricted to internal account and roles"
  # checkov:skip=CKV_AWS_111: "Write access allowed only for approved services"
  # checkov:skip=CKV_AWS_356: "Wildcard used in internal context and not public"

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
        format(
          "arn:aws:sts::%s:assumed-role/AWSS3BucketReplication-waf-logs/s3-replication",
          data.aws_caller_identity.current.account_id
        )
      ]
    }
  }
}

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

# Kinesis Firehose stream for centralized WAF logging
resource "aws_iam_role" "firehose_to_s3" {
  name = "firehose_to_s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "firehose.amazonaws.com",
            "logs.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_to_s3_policy" {
  role = aws_iam_role.firehose_to_s3.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${module.s3-bucket-modernisation-platform-waf-logs.bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.s3_modernisation_platform_waf_logs.arn
      },
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = "arn:aws:firehose:eu-west-2:${data.aws_caller_identity.current.account_id}:deliverystream/waf-logs-to-s3"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        # Resource = "*"
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/waf-logs-to-s3:*"
      }
    ]
  })
}

# This stream receives WAF logs from member accounts and delivers them to the centralized S3 bucket
resource "aws_kinesis_firehose_delivery_stream" "waf_logs_to_s3" {
  # checkov:skip=CKV_AWS_240: "Encryption is enabled with a CMK via kms_key_arn"
  # checkov:skip=CKV_AWS_241: "Encryption is enabled with a CMK via kms_key_arn"
  name        = "waf-logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_to_s3.arn
    bucket_arn         = module.s3-bucket-modernisation-platform-waf-logs.bucket.arn
    buffering_size     = 5
    buffering_interval = 300
    compression_format = "UNCOMPRESSED"
    kms_key_arn        = aws_kms_key.s3_modernisation_platform_waf_logs.arn
  }
}

# CloudWatch Logs Destination for cross-account log delivery
resource "aws_cloudwatch_log_destination" "waf_logs" {
  name       = "waf-logs-destination"
  role_arn   = aws_iam_role.cwl_to_firehose.arn
  target_arn = aws_kinesis_firehose_delivery_stream.waf_logs_to_s3.arn

  depends_on = [
    aws_kinesis_firehose_delivery_stream.waf_logs_to_s3,
    aws_iam_role_policy.cwl_to_firehose_policy
  ]
}

# Allows all member accounts to use this destination
resource "aws_cloudwatch_log_destination_policy" "waf_logs" {
  destination_name = aws_cloudwatch_log_destination.waf_logs.name
  access_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "logs:PutSubscriptionFilter",
      Resource  = aws_cloudwatch_log_destination.waf_logs.arn,
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
        }
      }
    }]
  })
}


resource "aws_iam_role" "cwl_to_firehose" {
  name = "CWLtoFirehoseRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect = "Allow",
      Principal : {
        Service = "logs.amazonaws.com"
      },
      Action : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cwl_to_firehose_policy" {
  name = "Permissions-Policy-For-CWL"
  role = aws_iam_role.cwl_to_firehose.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect   = "Allow",
      Action   = ["firehose:*"],
      Resource = [aws_kinesis_firehose_delivery_stream.waf_logs_to_s3.arn]
    }]
  })
}
