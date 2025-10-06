# Kinesis Firehose stream for centralized r53 public DNS query logging
resource "aws_iam_role" "firehose_to_s3_r53_public_dns" {
  name = "firehose_to_s3_r53_public_dns"
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

resource "aws_iam_role_policy" "firehose_to_s3_r53_public_dns_policy" {
  role = aws_iam_role.firehose_to_s3_r53_public_dns.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${module.s3_bucket_r53_public_dns_logs.bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.r53_public_dns_logs.arn
      },
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = "arn:aws:firehose:eu-west-2:${data.aws_caller_identity.current.account_id}:deliverystream/r53-public-dns-logs-to-s3"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/r53-public-dns-logs-to-s3:*"
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "r53_public_dns_logs_to_s3" {
  # checkov:skip=CKV_AWS_240: "Encryption is enabled with a CMK via kms_key_arn"
  # checkov:skip=CKV_AWS_241: "Encryption is enabled with a CMK via kms_key_arn"
  name        = "r53-public-dns-logs-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_to_s3_r53_public_dns.arn
    bucket_arn          = module.s3_bucket_r53_public_dns_logs.bucket.arn
    prefix              = "r53-public-dns-logs/"
    error_output_prefix = "r53-public-dns-logs-error/"
    buffering_interval  = 300
    buffering_size      = 5
    compression_format  = "GZIP"
    kms_key_arn         = aws_kms_key.r53_public_dns_logs.arn
  }

  depends_on = [aws_iam_role_policy.firehose_to_s3_r53_public_dns_policy]
}