locals {
  cortex_logging_buckets = toset(["vpc-flow-logs", "r53-resolver-logs", "generic-logs"])
}

resource "aws_s3_bucket" "logging" {
  # checkov:skip=CKV_AWS_18:  Access logs not presently required
  # checkov:skip=CKV_AWS_21:  Versioning of log objects not required
  # checkov:skip=CKV_AWS_144: Replication of log objects not required
  # checkov:skip=CKV_AWS_145: SSE Encryption OK as interim measure
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

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  for_each = local.cortex_logging_buckets
  bucket   = aws_s3_bucket.logging[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
