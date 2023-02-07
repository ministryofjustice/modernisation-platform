

resource "aws_route53_resolver_query_log_config" "dns_logs" {
  name            = "dns_logs"
  destination_arn = varlogging_destination_arn

  tags = var.tags_common
}

resource "aws_route53_resolver_query_log_config_association" "dns_logs" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.dns_logs.id
  resource_id                  = var.vpc_id

  tags = var.tags_common
}
