
# This generates the firehose stream resources to share VPC flow log data

locals {

  vpc_logs = toset([module.vpc["live_data"].vpc_cloudwatch_name, module.vpc["non_live_data"].vpc_cloudwatch_name])

}

module "firehose_core_logging_vpcs" {
  source          = "../../modules/firehose"
  for_each        = local.vpc_logs
  resource_prefix = format("%s-log", substr(each.value, 0, 3))
  log_group_name  = each.value
  tags            = local.tags
  xsiam_endpoint  = each.key == "live_data" ? local.xsiam["xsiam_prod_network_endpoint"] : local.xsiam["xsiam_preprod_network_endpoint"]
  xsiam_secret    = each.key == "live_data" ? local.xsiam["xsiam_prod_network_secret"] : local.xsiam["xsiam_preprod_network_secret"]
}