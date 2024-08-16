data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudwatch-logs-trust-policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com", ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:region:${data.aws_caller_identity.destination.account_id}:*"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch-logs-role-policy" {
  version = "2012-10-17"

  statement {
    sid    = "FirehoseToDeliveryStream"
    effect = "Allow"
    actions = [
      "firehose:PutRecord"
    ]
    resources = [
      "arn:aws:firehose:*:account-id:deliverystream/delivery-stream-name"
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
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      var.destination_bucket_arn,
      "${var.destination_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "firehose-key-policy" {
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
    sid    = "AllowFirehose"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["firehose.amazonaws.com"]
    }
  }
}
