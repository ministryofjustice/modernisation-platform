data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudwatch-logs-trust-policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.eu-west-2.amazonaws.com", ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch-logs-role-policy" {
  version = "2012-10-17"

  statement {
    sid    = "FirehoseToDeliveryStream"
    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.firehose-to-s3.arn
    ]
  }
}

data "aws_iam_policy_document" "firehose-trust-policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com", ]
    }
  }
}

data "aws_iam_policy_document" "firehose-role-policy" {
  version = "2012-10-17"

  statement {
    sid    = "FirehoseToS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      var.destination_bucket_arn,
      "${var.destination_bucket_arn}/*"
    ]
  }
  statement {
    sid    = "FirehoseUseKMS"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.firehose.arn
    ]
  }
  statement {
    sid    = "FirehosePutLogs"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.kinesis.arn}:log-stream:DestinationDelivery"
    ]
  }
}

data "aws_iam_policy_document" "firehose-key-policy" {
  # checkov:skip=CKV_AWS_109: Policy appropriately secure
  # checkov:skip=CKV_AWS_111
  # checkov:skip=CKV_AWS_356
  statement {
    sid    = "KeyAdministration"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowFirehoseRole"
    effect = "Allow"

    principals {
      identifiers = [
        aws_iam_role.cloudwatch-to-firehose.arn,
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}
