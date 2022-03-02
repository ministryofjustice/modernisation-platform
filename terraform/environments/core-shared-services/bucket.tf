module "imagebuilder_log_bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v6.0.1"

  providers = {
    aws.bucket-replication = aws.bucket-replication
  }

  bucket_prefix       = "ec2-image-builder-logs-"
  versioning_enabled  = false
  replication_enabled = false

  tags = local.tags
}

output "imagebuilder_log_bucket_id" {
  value = module.imagebuilder_log_bucket.bucket.id
}
