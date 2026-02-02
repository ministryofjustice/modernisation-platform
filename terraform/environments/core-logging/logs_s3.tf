locals {
  cortex_logging_buckets = toset(["vpc-flow-logs", "r53-resolver-logs", "generic-logs"])
}

resource "aws_s3_bucket" "logging" {
  # checkov:skip=CKV_AWS_18:  Access logs not presently required
  # checkov:skip=CKV_AWS_21:  Versioning of log objects not required
  # checkov:skip=CKV_AWS_144: Replication of log objects not required
  # checkov:skip=CKV2_AWS_6:  Public access blocked with for_each
  # checkov:skip=CKV2_AWS_61: Lifecycle configuration present with for_each
  # checkov:skip=CKV2_AWS_62: Notifications present with for_each
  for_each      = local.cortex_logging_buckets
  bucket_prefix = "${local.application_name}-${each.key}"
  tags          = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "logging" {
  for_each = local.cortex_logging_buckets
  bucket   = aws_s3_bucket.logging[each.key].id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    id = "rule-1"
    filter {
      prefix = ""
    }
    expiration {
      days = 14
    }
    status = "Enabled"
  }
}

# Because we can't use wildcards beyond "*" in a principal identifier, we use a policy condition to scope access only
data "aws_iam_policy_document" "logging-bucket" {
  for_each = local.cortex_logging_buckets
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logging[each.key].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        data.aws_organizations_organization.root_account.id
      ]
    }
  }
  statement {
    sid    = "AWSLogDeliveryCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logging[each.key].arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        data.aws_organizations_organization.root_account.id
      ]
    }
  }
  statement {
    sid     = "EnforceTLSv12orHigher"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.logging[each.key].arn,
      "${aws_s3_bucket.logging[each.key].arn}/*"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = [1.2]
    }
  }
}

resource "aws_s3_bucket_policy" "logging" {
  for_each = local.cortex_logging_buckets
  bucket   = aws_s3_bucket.logging[each.key].id
  policy   = data.aws_iam_policy_document.logging-bucket[each.key].json
}

resource "aws_s3_bucket_public_access_block" "logging" {
  for_each                = local.cortex_logging_buckets
  bucket                  = aws_s3_bucket.logging[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# checkov:skip=CKV_AWS_109: Scope constrained via principal
# checkov:skip=CKV_AWS_356: Wider permissions follows other kms policies
# checkov:skip=CKV_AWS_111: Wider permissions follows other kms policies
data "aws_iam_policy_document" "logging_kms" {
  for_each = local.cortex_logging_buckets

  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow AWS Log Delivery to use the key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceOrgID"
      values = [
        data.aws_organizations_organization.root_account.id
      ]
    }
  }
}

resource "aws_kms_key" "logging" {
  for_each                = local.cortex_logging_buckets
  description             = "KMS key for ${local.application_name}-${each.key} S3 bucket encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.logging_kms[each.key].json
  tags                    = local.tags
}

resource "aws_kms_alias" "logging" {
  for_each      = local.cortex_logging_buckets
  name          = "alias/${local.application_name}-${each.key}"
  target_key_id = aws_kms_key.logging[each.key].key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  for_each = local.cortex_logging_buckets
  bucket   = aws_s3_bucket.logging[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.logging[each.key].arn
    }
    bucket_key_enabled = true
  }
}
