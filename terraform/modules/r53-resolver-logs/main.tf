resource "aws_route53_resolver_query_log_config" "main" {
  name            = "dns_logs"
  destination_arn = var.logging_destination_arn
  tags = var.tags_common
}

resource "aws_route53_resolver_query_log_config_association" "main" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.main.id
  resource_id                  = var.vpc_id
  tags = var.tags_common
}