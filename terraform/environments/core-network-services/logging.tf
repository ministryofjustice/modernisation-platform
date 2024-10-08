locals {
  resolver_query_log_config_names = toset(["core-logging-rlq-cloudwatch", "core-logging-rlq-s3"])
  vpc_ids                         = { for key, value in module.vpc_inspection : key => value["vpc_id"] if key == "live_data" }
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

resource "aws_route53_resolver_query_log_config_association" "core_logging" {
  for_each                     = local.is-production ? local.vpc_rlq_associations : {}
  resolver_query_log_config_id = each.value.rlq_id
  resource_id                  = each.value.vpc_id
}

module "stream_firewall_logs" {
  source                     = "github.com/ministryofjustice/modernisation-platform-terraform-aws-data-firehose?ref=fe5220c39053d52e33ef6feeec0245d65a8157f3"
  cloudwatch_log_group_names = [module.vpc_inspection["live_data"].fw_cloudwatch_name, aws_cloudwatch_log_group.external_inspection.name]
  destination_http_endpoint  = data.aws_ssm_parameter.cortex_xsiam_endpoint.value
  tags                       = local.tags
}