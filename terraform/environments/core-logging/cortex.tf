# Because we can't use wildcards beyond "*" in a principal identifier, we use a policy condition to scope access only
# to accounts in our OU, where the role matches the name created through the cloudwatch-firehose module
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
    resources = flatten([
      for bucket in aws_s3_bucket.logging :
      [bucket.arn, "${bucket.arn}/*"]
    ])
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
      for key in aws_sqs_queue.logging : key.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [for key in aws_s3_bucket.logging : key.arn]
    }
  }
}

locals {
  cortex_logging_buckets = toset(["vpc-flow-logs", "r53-resolver-logs", "generic-logs"])
}

resource "aws_s3_bucket" "logging" {
  #  checkov:skip=CKV_AWS_18: Access logs not presently required
  #  checkov:skip=CKV_AWS_21: Versioning of log objects not required
  #  checkov:skip=CKV_AWS_144:Replication of log objects not required
  #  checkov:skip=CKV_AWS_145:SSE Encryption OK as interim measure
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
    filter {}
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
  policy   = data.aws_iam_policy_document.logging-bucket.json
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
  for_each                   = local.cortex_logging_buckets
  name_prefix                = "${local.application_name}-${each.key}"
  delay_seconds              = 0      # The default is 0 but can be up to 15 minutes
  max_message_size           = 262144 # 256k which is the max size
  message_retention_seconds  = 345600 # This is 4 days. The max is 14 days
  sqs_managed_sse_enabled    = true   # Using managed encryption
  visibility_timeout_seconds = 30     # This is only useful for queues that have multiple subscribers
  tags                       = local.tags
}

resource "aws_sqs_queue_policy" "logging" {
  for_each  = local.cortex_logging_buckets
  policy    = data.aws_iam_policy_document.logging-sqs.json
  queue_url = aws_sqs_queue.logging[each.key].url
}

data "aws_kms_alias" "secrets" {
  provider = aws.modernisation-platform
  name     = "alias/secrets_key"
}

resource "aws_secretsmanager_secret" "logging" {
  # checkov:skip=CKV2_AWS_57
  provider                = aws.modernisation-platform
  kms_key_id              = data.aws_kms_alias.secrets.target_key_id
  name                    = "core_logging_bucket_arns"
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "logging" {
  provider  = aws.modernisation-platform
  secret_id = aws_secretsmanager_secret.logging.id
  secret_string = jsonencode({
    for key in local.cortex_logging_buckets :
    key => aws_s3_bucket.logging[key].arn
  })
}
