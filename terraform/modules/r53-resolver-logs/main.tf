resource "aws_route53_resolver_query_log_config" "main" {
  name            = format("%s-r53-resolver-logs", var.vpc_name)
  destination_arn = aws_cloudwatch_log_group.main.arn
  tags            = var.tags_common
}

resource "aws_route53_resolver_query_log_config_association" "main" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.main.id
  resource_id                  = var.vpc_id
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "main" {
  #checkov:skip=CKV_AWS_158:"Standard encryption is enough"
  name              = format("%s-r53-resolver-logs", var.vpc_name)
  retention_in_days = 365
}

output "r53_resolver_log_name" {
  value = aws_cloudwatch_log_group.main.name
}
