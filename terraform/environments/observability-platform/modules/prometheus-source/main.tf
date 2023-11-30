data "aws_iam_policy_document" "prometheus_write" {
  statement {
    sid    = "AllowRemoteWrite"
    effect = "Allow"
    actions = [
      "aps:RemoteWrite",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata"
    ]
    resources = [var.workspace_arn]
  }
}

module "observability_platform_prometheus_policy" {
  #checkov:skip=CKV_TF_1:Module is from Terraform registry

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name_prefix = "observability-platform-prometheus"

  policy = data.aws_iam_policy_document.prometheus_write.json
}

module "observability_platform_prometheus_role" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions

  for_each = toset(var.datasource_names)

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role             = true
  role_name               = "${each.key}-prometheus"
  trusted_role_arns       = ["arn:aws:iam::${var.environment_management.account_ids[each.key]}:root"]
  custom_role_policy_arns = [module.observability_platform_prometheus_policy.arn]
  role_requires_mfa       = false
}
