// TODO: clean up this resource
module "eks_backup_bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v7.0.0"

  providers = {
    aws.bucket-replication = aws
  }

  bucket_prefix = "moj-dp-${local.environment}-velero"

  tags = local.tags
}

module "velero_s3_bucket" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v7.0.0"

  providers = {
    aws.bucket-replication = aws
  }

  bucket_prefix = "moj-data-platform-velero-${local.environment}"

  tags = local.tags
}
