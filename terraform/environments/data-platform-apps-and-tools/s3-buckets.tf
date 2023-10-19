module "velero_s3_bucket" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=v7.1.0"

  providers = {
    aws.bucket-replication = aws
  }

  bucket_prefix = "moj-data-platform-${local.environment}-velero"

  tags = local.tags
}
