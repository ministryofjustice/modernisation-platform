

resource "aws_route53_resolver_query_log_config" "dns_logs" {
  name            = "dns_logs"
  destination_arn = aws_cloudwatch_log_group.aws_route53_logs_com.arn
}

resource "aws_route53_resolver_query_log_config_association" "dns_logs" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.dns_logs.id
  resource_id                  = var.vpc_id
}
