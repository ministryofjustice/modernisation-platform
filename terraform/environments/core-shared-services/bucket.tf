# tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-encryption-customer-key
module "imagebuilder_log_bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=c67758cd6d263bec9c225b99b6f76d6074514159"

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }

  bucket_prefix               = "ec2-image-builder-logs-"
  sse_algorithm               = "aws:kms"
  custom_kms_key              = aws_kms_key.imagebuilder_logs.arn
  enforce_kms_request_headers = false
  versioning_enabled          = false
  replication_enabled         = false

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
      prefix  = ""
      tags    = {}
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]
      expiration = {
        days = 730
      }
      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
          }, {
          days          = 365
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        days = 730
      }
    }
  ]


  tags = local.tags
}

# Customer-managed KMS key for Image Builder log bucket
resource "aws_kms_key" "imagebuilder_logs" {
  description             = "KMS key for EC2 Image Builder log bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowS3UseOfTheKey"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

resource "aws_kms_alias" "imagebuilder_logs" {
  name          = "alias/imagebuilder-log-bucket"
  target_key_id = aws_kms_key.imagebuilder_logs.key_id
}

output "imagebuilder_log_bucket_id" {
  value = module.imagebuilder_log_bucket.bucket.id
}
