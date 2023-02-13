data "aws_caller_identity" "current" {}

resource "aws_route53_resolver_query_log_config" "main" {
  name            = format("%s-r53-resolver-logs", var.vpc_name)
  destination_arn = aws_cloudwatch_log_group.main.arn
  tags            = var.tags_common
}

resource "aws_route53_resolver_query_log_config_association" "main" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.main.id
  resource_id                  = var.vpc_id
}

resource "aws_cloudwatch_log_group" "main" {
  name              = format("%s-r53-resolver-logs", var.vpc_name)
  retention_in_days = 365
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = format("%s-r53-query-logging-policy", var.vpc_name)
}

data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [aws_cloudwatch_log_group.main.arn]

    principals {
      identifiers = ["route53resolver.amazonaws.com"]
      type        = "Service"
    }
  }
}
