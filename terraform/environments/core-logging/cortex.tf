locals {
  cortex_logging_buckets = toset(["vpc-flow-logs", "r53-resolver-logs", "generic-logs"])
}

resource "random_uuid" "cortex" {}

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

data "aws_iam_policy_document" "logging-sqs" {
  for_each = local.cortex_logging_buckets
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.logging[each.key].arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.logging[each.key].arn]
    }
  }
}

data "aws_iam_policy_document" "cortex_user_policy" {
  statement {
    sid    = "SQSQueueReceiveMessages"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues"
    ]
    resources = flatten([
      aws_sqs_queue.mp_cloudtrail_log_queue.arn,
      aws_sqs_queue.mp_modernisation_platform_waf_logs_queue.arn,
      [for key in aws_sqs_queue.logging : key.arn]
    ])
  }
  statement {
    sid     = "S3GetLogs"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = concat(
      [
        module.s3-bucket-cloudtrail.bucket.arn,
        "${module.s3-bucket-cloudtrail.bucket.arn}/*",
        module.s3-bucket-modernisation-platform-waf-logs.bucket.arn,
        "${module.s3-bucket-modernisation-platform-waf-logs.bucket.arn}/*"
      ],
      [for key in aws_s3_bucket.logging : "${key.arn}/*"]
    )
  }
}

data "aws_iam_policy_document" "cortex_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${aws_ssm_parameter.cortex_account_id.insecure_value}:root"]
      # Palo Alto Cortex AWS Account ID
      # Taken from https://docs-cortex.paloaltonetworks.com/r/Cortex-XDR/Cortex-XDR-Pro-Administrator-Guide/Create-an-Assumed-Role
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [sensitive(random_uuid.cortex.result)]
    }
  }
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

resource "aws_s3_bucket_notification" "logging" {
  for_each = local.cortex_logging_buckets
  bucket   = aws_s3_bucket.logging[each.key].id
  queue {
    queue_arn = aws_sqs_queue.logging[each.key].arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
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

resource "aws_sqs_queue" "logging" {
  for_each                = local.cortex_logging_buckets
  name_prefix             = "${local.application_name}-${each.key}"
  sqs_managed_sse_enabled = true # Using managed encryption
  tags                    = local.tags
}

resource "aws_sqs_queue_policy" "logging" {
  for_each  = local.cortex_logging_buckets
  policy    = data.aws_iam_policy_document.logging-sqs[each.key].json
  queue_url = aws_sqs_queue.logging[each.key].url
}

resource "aws_iam_policy" "cortex_xsiam_policy" {
  name        = "cortex-user-policy"
  description = "Allows the access to the created SQS queue"
  policy      = data.aws_iam_policy_document.cortex_user_policy.json
}

resource "aws_iam_role" "cortex_xsiam_role" {
  description        = "Role utilised by Palo Alto Cortex XSIAM"
  name_prefix        = "cortex_xsiam"
  assume_role_policy = data.aws_iam_policy_document.cortex_trust_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "cortex_xsiam_role" {
  policy_arn = aws_iam_policy.cortex_xsiam_policy.arn

  role = aws_iam_role.cortex_xsiam_role.name
}