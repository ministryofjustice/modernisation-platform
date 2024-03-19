
# The purpose of this module call is to generate firehose & related resources for each cloudwatch log group created for the inline & external inspection firewalls.
# This uses the cloudwatch log names outputted from the vpc inspection firewall module as well as the log group created for the external inspection firewall

module "external_inspection_firehose" {
  source          = "../../modules/firehose"
  for_each        = toset([module.vpc_inspection["live_data"].fw_cloudwatch_name, module.vpc_inspection["non_live_data"].fw_cloudwatch_name, module.firewall_logging.cloudwatch_log_group_name])
  resource_prefix = each.value
  log_group_name  = each.value
  tags            = local.tags
  xsiam_endpoint  = each.value != "fw-non-live_data*" ? tostring(local.xsiam["xsiam_prod_firewall_endpoint"]) : tostring(local.xsiam["xsiam_nonprod_firewall_endpoint"])
  xsiam_secret    = each.value != "fw-non-live_data*" ? tostring(local.xsiam["xsiam_prod_firewall_secret"]) : tostring(local.xsiam["xsiam_nonprod_firewall_secret"])
}