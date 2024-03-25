
# The purpose of this module call is to generate firehose & related resources for each R53 resolver log in core-vpc

# We are only building for production & development.


module "firehose_r53_resolver_logs" {
  source          = "../../modules/firehose"  
  for_each = { for key, value in module.vpc : 
            key => value["vpc_id"] 
            if anytrue(local.is-development, local.is-production) }
    common_attribute          = "${each.key}-${local.application_name}"
    resource_prefix           = format("R53-%s",each.key) # We do this to ensure the resource names are unique
    log_group_name            = module.route_53_resolver_logs[each.key].r53_resolver_log_name
    tags                      = local.tags
    xsiam_endpoint            = local.is-production ? tostring(local.xsiam["xsiam_prod_network_endpoint"]): tostring(local.xsiam["xsiam_preprod_network_endpoint"])
    xsiam_secret              = local.is-production ? tostring(local.xsiam["xsiam_prod_network_secret"]) : tostring(local.xsiam["xsiam_preprod_network_secret"])
}