
# The purpose of this module call is to generate firehose & related resources for each R53 resolver log in core-vpc

# We are only building for production & development.


module "firehose_r53_resolver_logs" {
  source           = "../../modules/firehose"
  for_each         = { for key, value in module.vpc : key => value["vpc_id"] if anytrue([local.is-development, local.is-production]) }
  common_attribute = "${local.application_name}-${each.key}"
  resource_prefix  = format("R53-%s", each.key) # We do this to ensure the resource names are unique
  log_group_name   = module.route_53_resolver_logs[each.key].r53_resolver_log_name
  tags             = local.tags
  xsiam_endpoint   = each.value == "live_data" ? local.xsiam["xsiam_prod_network_endpoint"] : local.xsiam["xsiam_preprod_network_endpoint"]
  xsiam_secret     = each.value == "live_data" ? local.xsiam["xsiam_prod_r53_secret"] : local.xsiam["xsiam_preprod_r53_secret"]
}