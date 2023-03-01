# tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-encryption-customer-key
module "imagebuilder_log_bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v6.3.0"

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }

  bucket_prefix       = "ec2-image-builder-logs-"
  versioning_enabled  = false
  replication_enabled = false

  lifecycle_rule = [
    {
      id      = "main"
      enabled = "Enabled"
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

output "imagebuilder_log_bucket_id" {
  value = module.imagebuilder_log_bucket.bucket.id
}
