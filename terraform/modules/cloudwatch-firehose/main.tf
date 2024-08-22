resource "random_id" "name" {
  byte_length = 4
}

resource "aws_kms_key" "firehose" {
  # checkov:skip=CKV_AWS_7
  description             = "KMS key for Firehose delivery streams"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.firehose-key-policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "firehose" {
  name          = "alias/firehose-log-delivery"
  target_key_id = aws_kms_key.firehose.id
}

resource "aws_iam_role" "firehose-to-s3" {
  assume_role_policy = data.aws_iam_policy_document.firehose-trust-policy.json
  name_prefix        = "firehose-to-s3"
  tags               = var.tags
}

resource "aws_iam_policy" "firehose-to-s3" {
  name_prefix = "firehose-to-s3"
  policy      = data.aws_iam_policy_document.firehose-role-policy.json
  tags        = var.tags
}

resource "aws_iam_policy_attachment" "firehose-to-s3" {
  name       = "${aws_iam_role.firehose-to-s3.name}-policy"
  policy_arn = aws_iam_policy.firehose-to-s3.arn
  roles      = [aws_iam_role.firehose-to-s3.name]
}

resource "aws_iam_role" "cloudwatch-to-firehose" {
  assume_role_policy = data.aws_iam_policy_document.cloudwatch-logs-trust-policy.json
  name_prefix        = "cloudwatch-to-firehose"
  tags               = var.tags
}

resource "aws_iam_policy" "cloudwatch-to-firehose" {
  name_prefix = "cloudwatch-to-firehose"
  policy      = data.aws_iam_policy_document.cloudwatch-logs-role-policy.json
  tags        = var.tags
}

resource "aws_iam_policy_attachment" "cloudwatch-to-firehose" {
  name       = "${aws_iam_role.cloudwatch-to-firehose.name}-policy"
  policy_arn = aws_iam_policy.cloudwatch-to-firehose.arn
  roles      = [aws_iam_role.cloudwatch-to-firehose.name]
}

resource "aws_kinesis_firehose_delivery_stream" "firehose-to-s3" {
  destination = "extended_s3"
  name        = "cloudwatch-to-s3-${random_id.name.hex}"

  extended_s3_configuration {
    bucket_arn          = var.destination_bucket_arn
    buffering_size      = 64
    buffering_interval  = 60
    compression_format  = "GZIP"
    role_arn            = aws_iam_role.firehose-to-s3.arn
    prefix              = "logs/!{timestamp:yyyy/MM/dd}/"
    error_output_prefix = "errors/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.kinesis.name
      log_stream_name = "DestinationDelivery"
    }

    dynamic_partitioning_configuration {
      enabled = false
    }
  }

  server_side_encryption {
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = aws_kms_key.firehose.arn
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "kinesis" {
  #  checkov:skip=CKV_AWS_338:Short life error logs don't need long term retention
  #  checkov:skip=CKV_AWS_158:Default log encryption OK for short life error logs
  name              = "/aws/kinesisfirehose/cloudwatch-to-s3-${random_id.name.hex}"
  retention_in_days = 14
  tags              = var.tags
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch-to-firehose" {
  for_each        = toset(var.cloudwatch_log_groups)
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose-to-s3.arn
  filter_pattern  = "" # Left empty to stream all logs
  log_group_name  = each.key
  name            = "firehose-delivery-${each.key}"
  role_arn        = aws_iam_role.cloudwatch-to-firehose.arn
}
