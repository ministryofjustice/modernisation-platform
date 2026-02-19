module "s3_bucket_no_lock" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=feature/spike-object-lock"

  bucket_prefix      = "cook-no-lock-test"
  versioning_enabled = true

  object_lock_enabled = false

  providers = {
    aws.bucket-replication = aws
  }

  tags = local.tags
}


module "s3_bucket_compliance_lock" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket?ref=feature/spike-object-lock"

  bucket_prefix      = "cook-governance-lock-test"
  versioning_enabled = true

  object_lock_enabled = true
  object_lock_mode    = "COMPLIANCE"
  object_lock_days    = 1

  providers = {
    aws.bucket-replication = aws
  }

  tags = local.tags
}

