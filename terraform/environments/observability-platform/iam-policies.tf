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