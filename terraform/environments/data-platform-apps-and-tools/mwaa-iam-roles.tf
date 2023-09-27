module "airflow_execution_role" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true

  role_name         = local.environment_configuration.airflow_execution_role_name
  role_requires_mfa = false

  trusted_role_services = [
    "airflow.amazonaws.com",
    "airflow-env.amazonaws.com"
  ]

  custom_role_policy_arns = [module.airflow_execution_policy.arn]

  tags = local.tags
}
