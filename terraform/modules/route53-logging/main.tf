

resource "aws_route53_resolver_query_log_config" "dns_logs" {
  name            = "dns_logs"
  destination_arn = "arn:aws:logs:eu-west-2:${local.environment_management.account_ids[terraform.workspace]}:log-group:aws_route53_logs:*"

  tags = var.tags_common
}

resource "aws_route53_resolver_query_log_config_association" "dns_logs" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.dns_logs.id
  resource_id                  = var.vpc_id

  tags = var.tags_common
}
