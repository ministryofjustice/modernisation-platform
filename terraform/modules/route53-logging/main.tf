

resource "aws_route53_resolver_query_log_config" "dns_logs" {
  name            = "dns_logs"
  destination_arn = aws_cloudwatch_log_group.aws_route53_logs_com.arn
<<<<<<< HEAD
=======

  tags = {

  }
>>>>>>> e4551b36cdccae614c211f812b80419d1b2e6c49
}

resource "aws_route53_resolver_query_log_config_association" "dns_logs" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.dns_logs.id
  resource_id                  = var.vpc_id
}
