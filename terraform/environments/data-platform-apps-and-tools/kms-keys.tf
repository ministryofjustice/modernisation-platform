module "openmetadata_efs_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["efs/openmetadata"]
  description           = "Open Metadata EFS"
  enable_default_policy = true

  deletion_window_in_days = 7

  tags = local.tags
}

// TODO:
//   - KMS key for RDS
//     - key per RDS (Airflow and OpenMetadata)
//   - KMS key for OpenSearch
