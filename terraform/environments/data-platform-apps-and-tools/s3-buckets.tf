module "velero_s3_bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v7.0.0"

  providers = {
    aws.bucket-replication = aws
  }

  bucket_prefix = "moj-data-platform-${local.environment}-velero"

  tags = local.tags
}
