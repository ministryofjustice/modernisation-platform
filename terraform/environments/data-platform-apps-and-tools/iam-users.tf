module "airflow_iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "2517eb98a39500897feecd27178994055ee2eb5e"

  name                          = "${local.application_name}-${local.environment}-${local.environment}-airflow"
  create_iam_user_login_profile = false

  tags = local.tags
}
