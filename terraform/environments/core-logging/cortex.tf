# Because we can't use wildcards beyond "*" in a principal identifier
data "aws_iam_policy_document" "logging-bucket" {
  statement {
    sid    = "AllowFirehosePutObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      aws_s3_bucket.logging.arn,
      "${aws_s3_bucket.logging.arn}/*"
    ]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values = [
        "${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"
      ]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/firehose-to-s3*"]
    }
  }
}

data "aws_iam_policy_document" "logging-sqs" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.logging.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.logging.arn]
    }
  }
}

resource "aws_s3_bucket" "logging" {
  #  checkov:skip=CKV_AWS_18: Access logs not presently required
  #  checkov:skip=CKV_AWS_21: Versioning of log objects not required
  #  checkov:skip=CKV_AWS_144:Replication of log objects not required
  bucket_prefix = terraform.workspace
  tags          = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.logging.id

  rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    id = "rule-1"
    filter {}
    expiration {
      days = 14
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_notification" "logging" {
  bucket = aws_s3_bucket.logging.id
  queue {
    queue_arn = aws_sqs_queue.logging.arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
  }
}

resource "aws_s3_bucket_policy" "logging" {
  bucket = aws_s3_bucket.logging.id
  policy = data.aws_iam_policy_document.logging-bucket.json
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_sqs_queue" "logging" {
  name_prefix                = terraform.workspace
  delay_seconds              = 0      # The default is 0 but can be up to 15 minutes
  max_message_size           = 262144 # 256k which is the max size
  message_retention_seconds  = 345600 # This is 4 days. The max is 14 days
  sqs_managed_sse_enabled    = true   # Using managed encryption
  visibility_timeout_seconds = 30     # This is only useful for queues that have multiple subscribers
  tags                       = local.tags
}

resource "aws_sqs_queue_policy" "logging" {
  policy    = data.aws_iam_policy_document.logging-sqs.json
  queue_url = aws_sqs_queue.logging.url
}
