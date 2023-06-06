module "airflow_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.20.0"

  name                          = "data-platform-${local.environment}-airflow"
  create_iam_user_login_profile = false

  tags = local.tags
}
