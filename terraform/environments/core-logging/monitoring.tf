module "core_monitoring" {
  source                     = "../../modules/core-monitoring"
  pagerduty_integration_keys = local.pagerduty_integration_keys
}
resource "aws_cloudwatch_log_group" "aws_route53_logs_com" {
  name              = "aws_route53_logs"
  retention_in_days = 365
}

data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {

  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}
