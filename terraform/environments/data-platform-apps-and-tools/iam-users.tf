module "airflow_iam_user" {
  # checkov:skip=CKV_TF_1:
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 5"

  name                          = "${local.application_name}-${local.environment}-airflow"
  create_iam_user_login_profile = false

  tags = local.tags
}
