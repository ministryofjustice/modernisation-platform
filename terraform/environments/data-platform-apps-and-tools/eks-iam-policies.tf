data "aws_iam_policy_document" "openmetadata_airflow" {
  statement {
    sid       = "AllowAssumeRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = formatlist("arn:aws:iam::%s:role/${local.environment_configuration.openmetadata_role}", local.environment_configuration.openmetadata_target_accounts)
  }
}

module "openmetadata_airflow_iam_policy" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name_prefix = "openmetadata-airflow"

  policy = data.aws_iam_policy_document.openmetadata_airflow.json
}

data "aws_iam_policy_document" "prometheus" {
  statement {
    sid       = "AllowAssumeRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${local.environment_configuration.observability_platform_account_id}:role/${local.environment_configuration.observability_platform_role}"]
  }
}

module "prometheus_iam_policy" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name_prefix = "prometheus"

  policy = data.aws_iam_policy_document.prometheus.json
}
