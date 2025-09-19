locals {
  resolver_query_log_config_names = toset(["core-logging-rlq-cloudwatch", "core-logging-rlq-s3"])
  vpc_ids                         = { for key, value in module.vpc : key => value["vpc_id"] if key == "live_data" }
  rlq_ids                         = { for name, config in data.aws_route53_resolver_query_log_config.core_logging : name => config.id }
  vpc_rlq_associations = merge([
    for vpc_key, vpc_id in local.vpc_ids : {
      for rlq_name, rlq_id in local.rlq_ids :
      "${vpc_key}_${rlq_name}" => {
        vpc_id = vpc_id
        rlq_id = rlq_id
      }
    }
  ]...)
}

data "aws_route53_resolver_query_log_config" "core_logging" {
  for_each = local.resolver_query_log_config_names
  filter {
    name   = "Name"
    values = [each.value]
  }
}
resource "aws_route53_resolver_query_log_config" "s3" {
  name            = format("%s-rlq-s3", local.application_name)
  destination_arn = aws_s3_bucket.logging["r53-resolver-logs"].arn
  tags            = local.tags
}

resource "aws_route53_resolver_query_log_config" "s3_eu_west_1" {
  provider        = aws.modernisation-platform-eu-west-1
  name            = format("%s-rlq-s3-%s", local.application_name, "eu-west-1")
  destination_arn = aws_s3_bucket.logging["r53-resolver-logs"].arn
  tags            = local.tags
}

resource "aws_route53_resolver_query_log_config" "cloudwatch" {
  name            = format("%s-rlq-cloudwatch", local.application_name)
  destination_arn = aws_cloudwatch_log_group.r53_resolver_logs.arn
  tags            = local.tags
}

resource "aws_cloudwatch_log_group" "r53_resolver_logs" {
  kms_key_id        = aws_kms_key.r53_resolver_logs.arn
  name_prefix       = "r53-resolver-logs"
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_route53_resolver_query_log_config_association" "core_logging" {
  for_each                     = local.is-production ? local.vpc_rlq_associations : {}
  resolver_query_log_config_id = each.value.rlq_id
  resource_id                  = each.value.vpc_id
}
