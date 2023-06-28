module "airflow_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "c1e20a227ca5c8f2953c5827533a2dc46696d3bb"

  name                          = "${local.application_name}-${local.environment}-${local.environment}-airflow"
  create_iam_user_login_profile = false

  tags = local.tags
}
