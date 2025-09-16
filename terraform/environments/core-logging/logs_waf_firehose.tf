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
