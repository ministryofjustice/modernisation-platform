module "data_platform_apps_tools_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role             = true
  role_name               = "data-platform-apps-and-tools"
  trusted_role_arns       = ["arn:aws:iam::${local.environment_configuration.data_platform_apps_tools_account_id}:root"]
  custom_role_policy_arns = [module.amazon_managed_prometheus_iam_policy.arn]
  role_requires_mfa       = false

  tags = local.tags
}
