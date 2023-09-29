module "openmetadata_efs_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["efs/openmetadata"]
  description           = "EFS customer managed key for Open Metadata Airflow"
  enable_default_policy = true

  deletion_window_in_days = 7

  tags = local.tags
}