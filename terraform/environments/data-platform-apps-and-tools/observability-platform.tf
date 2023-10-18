module "observability_platform_iam_role" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true

  role_name         = "observability-platform"
  role_requires_mfa = false

  trusted_role_arns = [
    "arn:aws:iam::${local.environment_configuration.observability_platform_account_id}:root"
  ]

  custom_role_policy_arns = ["arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"]

  tags = local.tags
}
