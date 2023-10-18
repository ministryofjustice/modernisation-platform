data "aws_iam_policy_document" "amazon_managed_prometheus" {
  statement {
    sid    = "AllowRemoteWrite"
    effect = "Allow"
    actions = [
      "aps:RemoteWrite",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata"
    ]
    resources = [module.managed_prometheus.workspace_arn]
  }
}

module "amazon_managed_prometheus_iam_policy" {
  #checkov:skip=CKV_TF_1:Module is from Terraform registry

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name_prefix = "amazon-managed-prometheus"

  policy = data.aws_iam_policy_document.amazon_managed_prometheus.json
}

data "aws_iam_policy_document" "amazon_managed_prometheus_remote_cloudwatch" {
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::${local.environment_configuration.data_platform_apps_tools_account_id}:role/observability-platform"
    ]
  }
}

module "amazon_managed_prometheus_remote_cloudwatch_iam_policy" {
  #checkov:skip=CKV_TF_1:Module is from Terraform registry

  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name_prefix = "amazon-managed-prometheus-remote-cloudwatch"

  policy = data.aws_iam_policy_document.amazon_managed_prometheus_remote_cloudwatch.json
}
