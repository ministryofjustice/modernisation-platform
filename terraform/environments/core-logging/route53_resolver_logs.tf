resource "aws_cloudwatch_log_group" "modernisation-platform-r53-resolver-logs" {
  provider          = aws.us-east-1
  name              = "modernisation-platform-r53-resolver-logs"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}

data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:modernisation-platform-r53-resolver-logs"]

    principals {
      identifiers = ["route53resolver.amazonaws.com"]
      type        = "Service"
    }
  }
}
