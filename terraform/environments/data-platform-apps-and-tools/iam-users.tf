module "airflow_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.20.0"

  name                          = "${local.application_name}-${local.environment}-${local.environment}-airflow"
  create_iam_user_login_profile = false

  tags = local.tags
}
