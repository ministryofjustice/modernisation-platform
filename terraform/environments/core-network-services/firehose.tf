
# The purpose of this module call is to generate firehose & related resources for each cloudwatch log group created for the inline & external inspection firewalls.
# This uses the cloudwatch log names outputted from the vpc inspection firewall module as well as the log group created for the external inspection firewall

locals {

  firewall_logs = toset([module.vpc_inspection["live_data"].fw_cloudwatch_name, module.vpc_inspection["non_live_data"].fw_cloudwatch_name, module.firewall_logging.cloudwatch_log_group_name])

  firewall_vpc_logs = toset([module.vpc_inspection["live_data"].vpc_cloudwatch_name, module.vpc_inspection["non_live_data"].vpc_cloudwatch_name, aws_cloudwatch_log_group.external_inspection.name])

}

# The initial call is for the creation of firehose stream resources for the firewall inspection logs.

module "firehose_firewalls" {
  source          = "../../modules/firehose"
  for_each        = local.firewall_logs
  resource_prefix = substr(each.value, 3, 3) # We do this because the log name is too long and we want to avoid any invalid characters.
  common_attribute          = "${each.key}-${local.application_name}"
  log_group_name  = each.value
  tags            = local.tags
  xsiam_endpoint  = substr(each.value, 3, 3) != "non" ? tostring(local.xsiam["xsiam_prod_firewall_endpoint"]) : tostring(local.xsiam["xsiam_preprod_firewall_endpoint"])
  xsiam_secret    = substr(each.value, 3, 3) != "non" ? tostring(local.xsiam["xsiam_prod_firewall_secret"]) : tostring(local.xsiam["xsiam_preprod_firewall_secret"])
}

# A 2nd call of the module which will generate the firehose streams for the firewall vpc flow logs.

module "firehose_vpcs" {
  source          = "../../modules/firehose"
  for_each        = local.firewall_vpc_logs
  resource_prefix = format("%s-vpc", substr(each.value, 0, 3)) # As above but we add an additional identifier
  common_attribute          = "${each.key}-${local.application_name}"
  log_group_name  = each.value
  tags            = local.tags
  xsiam_endpoint  = substr(each.value, 0, 3) != "non" ? tostring(local.xsiam["xsiam_prod_network_endpoint"]) : tostring(local.xsiam["xsiam_preprod_network_endpoint"])
  xsiam_secret    = substr(each.value, 0, 3) != "non" ? tostring(local.xsiam["xsiam_prod_network_secret"]) : tostring(local.xsiam["xsiam_preprod_network_secret"])
}