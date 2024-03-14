


# Firehose Resources for the sharing of network firewall inspection log data

resource "random_string" "firehose_rnd" {
  length  = 8
  special = false
  upper   = false
}


resource "aws_kinesis_firehose_delivery_stream" "delivery_stream" {
  #checkov:skip=CKV_AWS_241: We are using the default key for encryption.
  name        = format("%s-%s-%s", var.resource_prefix, "delivery-stream", random_string.firehose_rnd.result) 
  destination = "http_endpoint"
  tags = merge(
    var.tags,
    {
      Name = format("%s-%s-%s", var.resource_prefix, "delivery-stream", random_string.firehose_rnd.result) 
    }
  )

  server_side_encryption {
    enabled = true
  }

  http_endpoint_configuration {
    url                = var.xsiam_endpoint
    name               = format("%s-%s-%s", var.resource_prefix, "delivery-stream-endpoint-", random_string.firehose_rnd.result)
    access_key         = var.xsiam_secret
    buffering_size     = 5
    buffering_interval = 300
    role_arn           = aws_iam_role.delivery_stream_role.arn
    s3_backup_mode     = "FailedDataOnly"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.delivery_errors_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.delivery_errors_log_stream.name
    }

    s3_configuration {
      role_arn           = aws_iam_role.delivery_stream_role.arn
      bucket_arn         = aws_s3_bucket.firehose_error_logging_bucket.arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
    }

    request_configuration {
      content_encoding = "GZIP"

      common_attributes {
        name  = "Firewall Name & Log Type"
        value = var.resource_prefix
      }
    }

  }
}

# Cloudwatch Log Subscription Filters
# This acts as the interface between the flow log data in cloudwatch & the Firehose Stream.

resource "aws_cloudwatch_log_subscription_filter" "subscription_filter" {
  name            =  format("%s-%s-%s", var.resource_prefix, "subscription_filter", random_string.firehose_rnd.result) 
  role_arn        = aws_iam_role.xsiam_put_record_role.arn
  log_group_name  = var.log_group_name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.delivery_stream.arn
}

resource "aws_cloudwatch_log_group" "delivery_errors_log_group" {
  #checkov:skip=CKV_AWS_158:"Temporarily skip KMS encryption check while logging solution is being updated"
  name              = format("%s-%s-%s", var.resource_prefix, "delivery_errors_log_group", random_string.firehose_rnd.result) 
  tags = merge(
    var.tags,
    {
      Name = format("%s-%s-%s", var.resource_prefix, "delivery_errors_log_group", random_string.firehose_rnd.result) 
    }
  )
  retention_in_days = 400 # Because it's more than a year.
}

resource "aws_cloudwatch_log_stream" "delivery_errors_log_stream" {
  name           = format("%s-%s-%s", var.resource_prefix, "delivery_errors_log_stream", random_string.firehose_rnd.result)
  log_group_name = aws_cloudwatch_log_group.delivery_errors_log_group.name
}

# S3 Bucket to hold the transfer failure logs. We are using the default s3 key and no logging as it is not needed. We also have public access blocked by default

#tfsec:ignore:aws-ssm-secret-use-customer-key
#tfsec:ignore:aws-s3-encryption-customer-key
#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-specify-public-access-block
#tfsec:ignore:aws-s3-block-public-acls
#tfsec:ignore:aws-s3-block-public-policy
#tfsec:ignore:aws-s3-no-public-buckets
#tfsec:ignore:aws-s3-ignore-public-acls
resource "aws_s3_bucket" "firehose_error_logging_bucket" {
  #checkov:skip=CKV_AWS_241: We have encryption already in place using the default s3 kms key.
  #checkov:skip=CKV_AWS_21: We already have versioning enabled.
  #checkov:skip=CKV_AWS_145: We use the default encryption key.
  #checkov:skip=CKV2_AWS_62: We do not need event notifications enabled.
  #checkov:skip=CKV_AWS_144: We are not using cross-region replication.
  #checkov:skip=CKV_AWS_18: No access logging required
  #checkov:skip=CKV2_AWS_61: Lifecycle is enabled but this error still gets thrown.
  #checkov:skip=CKV2_AWS_6: Public Access Block enabled - see below - but the error still gets thrown.
  bucket = format("%s-%s-%s", var.resource_prefix, "firehose_error_logging_bucket", random_string.firehose_rnd.result) 
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.firehose_error_logging_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  #checkov:skip=CKV_AWS_300: Event notifications not used.
  bucket = aws_s3_bucket.firehose_error_logging_bucket.id
  rule {
    id = "delete-old"
    expiration {
      days = 366
    }
    status = "Enabled"
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

# Ideally we would not be using versioning of s3 files but it's added for the tfsec & checkov checks.
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.firehose_error_logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# By default s3 already blocks public access but this added for the tfsec & checkov checks.
resource "aws_s3_bucket_public_access_block" "bucket_block_public" {
  bucket                  = aws_s3_bucket.firehose_error_logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_iam_role" "delivery_stream_role" {
  name  = format("%s-%s-%s", var.resource_prefix, "delivery-stream-role", random_string.firehose_rnd.result)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(
    var.tags,
    {
      Name = format("%s-%s-%s", var.resource_prefix, "delivery-stream-role", random_string.firehose_rnd.result)
    }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "delivery_stream_role_policy" {
  #checkov:skip=CKV_AWS_355: - Ignore for now whilst we look into this.
  role  = aws_iam_role.delivery_stream_role.id
  name  = format("%s-%s-%s", var.resource_prefix, "delivery-stream-role-policy", random_string.firehose_rnd.result)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "logaccess"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ]
        Resource = "*"
      }
    ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "error_log_role_attachment" {
  policy_arn = aws_iam_policy.error_log_policy.arn
  role       = aws_iam_role.delivery_stream_role.name
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "error_log_policy" {
  name  = format("%s-%s-%s", var.resource_prefix, "error-log-policy", random_string.firehose_rnd.result)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
        ]
        Effect = "Allow"
        Resource = [
          "${aws_cloudwatch_log_group.delivery_errors_log_group.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_role_attachment" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.delivery_stream_role.name

}

#tfsec:ignore:aws-iam-no-policy-wildcards - this is to allow s3:AbortMultiPartUpload.
resource "aws_iam_policy" "s3_policy" {
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax. 
  name  = format("%s-%s-%s", var.resource_prefix, "s3-kinesis-xsiam-policy", random_string.firehose_rnd.result)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.firehose_error_logging_bucket.arn,
          "${aws_s3_bucket.firehose_error_logging_bucket.arn}/*"
        ]
      }
    ]
  })
}



resource "aws_iam_role" "xsiam_put_record_role" {
  name_prefix        = format("%s-%s-%s", var.resource_prefix, "xsiam-put-record-role", random_string.firehose_rnd.result) 
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "xsiam_put_record_policy" {
  name_prefix = format("%s-%s-%s", var.resource_prefix, "xsiam-put-record-policy", random_string.firehose_rnd.result) 
  policy      = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": [
                "${aws_kinesis_firehose_delivery_stream.delivery_stream.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "xsiam_put_record_policy_attachment" {
  role       = aws_iam_role.xsiam_put_record_role.name
  policy_arn = aws_iam_policy.xsiam_put_record_policy.arn
}



