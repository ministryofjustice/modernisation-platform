
# Secrets for Firehose Endpoint URL & Key

# For the Xsiam endpoint secret key
data "aws_secretsmanager_secret" "kinesis_preprod_firewall_secret_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_preprod_firewall_secret"
}

data "aws_secretsmanager_secret_version" "kinesis_preprod_firewall_secret_arn_version" {
  provider = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_preprod_firewall_secret_arn.id
}

# For the Xsiam endpoints URL
data "aws_secretsmanager_secret" "kinesis_preprod_firewall_endpoint_arn" {
  provider = aws.modernisation-platform
  name     = "xsiam_preprod_firewall_endpoint"
}

data "aws_secretsmanager_secret_version" "kinesis_preprod_firewall_endpoint_arn_version" {
  provider = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.kinesis_preprod_firewall_endpoint_arn.id
}

locals {

  firehose_preprod_firewall_secret      = jsondecode(data.aws_secretsmanager_secret_version.kinesis_preprod_firewall_secret_arn_version.secret_string)
  firehose_preprod_firewall_endpoint = jsondecode(data.aws_secretsmanager_secret_version.kinesis_preprod_firewall_endpoint_arn_version.secret_string)

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: core-network-services"
    is-production = "true"
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

}



# Firehose Resources for the sharing of network firewall inspection log data


resource "random_string" "firehose_rnd" {
  length  = 8
  special = false
  upper   = false
}

output "rnd_suffix" {
  value = random_string.firehose_rnd.result
}


resource "aws_kinesis_firehose_delivery_stream" "delivery_stream" {
  #checkov:skip=CKV_AWS_241: We are using the default key for encryption.
  name        = format("%s-%s", "delivery-stream", output.rnd_suffix.value) 
  destination = "http_endpoint"

    tags = merge(
    local.tags,
    {
      Name = format("%s-%s", "delivery-stream", output.rnd_suffix.value) 
    }
  )

  server_side_encryption {
    enabled = true
  }

  http_endpoint_configuration {
    url                = var.fw_name == "live-data-inline-inspection" ? tostring(local.firehose_prod_firewall_endpoint["xsiam_prod_firewall_endpoint"]): tostring(local.firehose_preprod_firewall_endpoint["xsiam_preprod_firewall_endpoint"])
    name               = format("%s-%s", "delivery-stream-endpoint-", output.rnd_suffix.value)
    access_key         = var.fw_name == "live-data-inline-inspection" ? tostring(local.firehose_prod_firewall_secret["xsiam_prod_firewall_secret"]): tostring(local.firehose_preprod_firewall_secret["xsiam_preprod_firewall_secret"])
    buffering_size     = 5
    buffering_interval = 300
    role_arn           = aws_iam_role.xsiam_kinesis_firehose_role.arn
    s3_backup_mode     = "FailedDataOnly"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.external_inspection_xsiam_delivery_errors_group.name
      log_stream_name = aws_cloudwatch_log_stream.external_inspection_xsiam_delivery_errors_stream.name
    }

    s3_configuration {
      role_arn           = aws_iam_role.xsiam_kinesis_firehose_role.arn
      bucket_arn         = module.s3-bucket.bucket.arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
    }

    request_configuration {
      content_encoding = "GZIP"

      common_attributes {
        name  = "Firewall Name"
        value = var.fw_name
      }
    }

  }
}

# Cloudwatch Log Subscription Filters
# This acts as the interface between the flow log data in cloudwatch & the Firehose Stream.

resource "aws_cloudwatch_log_subscription_filter" "subscription_filter" {
  name            =  format("%s-%s", "subscription_filter", output.rnd_suffix.value) 
  role_arn        = aws_iam_role.xsiam_put_record_role.arn
  log_group_name  = aws_cloudwatch_log_group.main.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.delivery_stream.arn
}

resource "aws_cloudwatch_log_group" "delivery_errors_log_group" {
  #checkov:skip=CKV_AWS_158:"Temporarily skip KMS encryption check while logging solution is being updated"
  name              = format("%s-%s", "delivery_errors_log_group", output.rnd_suffix.value) 
  tags = merge(
    local.tags,
    {
      Name = format("%s-%s", "delivery_errors_log_group", output.rnd_suffix.value) 
    }
  )
  retention_in_days = 400 # Because it's more than a year.
}

resource "aws_cloudwatch_log_stream" "delivery_errors_log_stream" {
  name           = format("%s-%s", "delivery_errors_log_stream", output.rnd_suffix.value)
  log_group_name = aws_cloudwatch_log_group.delivery_errors_group.name
}

module "s3-bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=568694e50e03630d99cb569eafa06a0b879a1239" #v7.1.0
  bucket_prefix                            = format("%s-%s", "error-logging", output.rnd_suffix.value)
  versioning_enabled                       = false
  # to disable ACLs in preference of BucketOwnership controls as per https://aws.amazon.com/blogs/aws/heads-up-amazon-s3-security-changes-are-coming-in-april-of-2023/ set:
  ownership_controls = "BucketOwnerEnforced"
  replication_enabled                      = false
  providers = {
    aws.bucket-replication = aws
  }
  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      prefix  = ""
      tags = {
        rule      = "log"
        autoclean = "true"
      }
      transition = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
          }, {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 730
      }
    }
  ]
  tags = merge(
    local.tags,
    {
      Name = format("%s-%s", "error-logging", output.rnd_suffix.value)
    }
  )
}



resource "aws_iam_role" "delivery_stream_role" {
  name  = format("%s-%s", "delivery-stream-role", output.rnd_suffix.value)
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
    local.tags,
    {
      Name = format("%s-%s", "delivery-stream-role", output.rnd_suffix.value)
    }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "delivery_stream_role_policy" {
  #checkov:skip=CKV_AWS_355: - Ignore for now whilst we look into this.
  role  = aws_iam_role.delivery_stream_role.id
  name  = format("%s-%s", "delivery-stream-role-policy", output.rnd_suffix.value)
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
  policy_arn = aws_iam_policy.delivery_stream_role_policy.arn
  role       = aws_iam_role.delivery_stream_role.name
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "error_log_policy" {
  name  = format("%s-%s", "error-log-policy", output.rnd_suffix.value)
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
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "s3_role_attachment" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.delivery_stream_role.name

}

#tfsec:ignore:aws-iam-no-policy-wildcards - this is to allow s3:AbortMultiPartUpload.
resource "aws_iam_policy" "s3_policy" {
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax. 
  name  = format("%s-%s", "s3-kinesis-xsiam-policy", output.rnd_suffix.value)
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
          module.s3-bucket.bucket.arn,
          "${module.s3-bucket.bucket.arn}/*"
        ]
      }
    ]
  })
  tags = local.tags
}



resource "aws_iam_role" "xsiam_put_record_role" {
  name_prefix        = format("%s-%s", "xsiam-put-record-role", output.rnd_suffix.value) 
  tags               = local.tags
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
  name_prefix = format("%s-%s", "xsiam-put-record-policy", output.rnd_suffix.value) 
  tags        = local.tags
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



