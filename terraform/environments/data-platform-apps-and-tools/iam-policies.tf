data "aws_iam_policy_document" "airflow_ses_policy" {
  statement {
    sid       = "AllowSESSendRawEmail"
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = ["arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/${local.environment_configuration.ses_domain_identity}"]
  }
}

module "airflow_ses_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "2517eb98a39500897feecd27178994055ee2eb5e"

  name   = "${local.application_name}-${local.environment}-airflow-ses"
  policy = data.aws_iam_policy_document.airflow_ses_policy.json

  tags = local.tags
}
