module "airflow_execution_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  role_name         = "${local.application_name}-${local.environment}-airflow-execution"
  role_requires_mfa = false
  create_role = true
  trusted_role_services = [
    "airflow.amazonaws.com",
    "airflow-env.amazonaws.com"
  ]

  custom_role_policy_arns = [module.airflow_execution_policy.arn]

  tags = local.tags
}
