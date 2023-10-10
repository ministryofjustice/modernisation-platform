module "openmetadata_efs_kms" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["efs/openmetadata"]
  description           = "Open Metadata EFS"
  enable_default_policy = true

  deletion_window_in_days = 7

  tags = local.tags
}

module "openmetadata_airflow_rds_kms" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["rds/openmetadata-airflow"]
  description           = "Open Metadata Airflow RDS"
  enable_default_policy = true

  deletion_window_in_days = 7

  tags = local.tags
}

module "openmetadata_rds_kms" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["rds/openmetadata"]
  description           = "Open Metadata RDS"
  enable_default_policy = true

  deletion_window_in_days = 7

  tags = local.tags
}

module "openmetadata_opensearch_kms" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  aliases               = ["opensearch/openmetadata"]
  description           = "Open Metadata OpenSearch"
  enable_default_policy = true

  deletion_window_in_days = 7

  tags = local.tags
}
