locals {
  networking = {
    live_data     = "10.20.0.0/19"
    non_live_data = "10.20.32.0/19"
  }
}

module "vpc_inspection" {
  for_each = local.networking

  source                  = "../../modules/vpc-inspection"
  application_name        = local.application_name
  fw_allowed_domains      = local.fqdn_firewall_rules.fw_allowed_domains
  fw_home_net_ips         = local.fqdn_firewall_rules.fw_home_net_ips
  fw_kms_arn              = data.aws_kms_key.general_shared.arn
  fw_rules                = local.inline_firewall_rules
  vpc_cidr                = each.value
  vpc_flow_log_iam_role   = data.aws_iam_role.vpc-flow-log.arn
  transit_gateway_id      = aws_ec2_transit_gateway.transit-gateway.id
  xsiam_network_endpoint  = each.key == "live_data" ? tostring(local.firehose_prod_network_endpoint["xsiam_prod_network_endpoint"]) : tostring(local.firehose_preprod_network_endpoint["xsiam_preprod_network_endpoint"])
  xsiam_network_secret    = each.key == "live_data" ? tostring(local.firehose_prod_network_secret["xsiam_prod_network_secret"]) : tostring(local.firehose_preprod_network_secret["xsiam_preprod_network_secret"])
  xsiam_firewall_endpoint = each.key == "live_data" ? tostring(local.firehose_prod_firewall_endpoint["xsiam_prod_firewall_endpoint"]) : tostring(local.firehose_preprod_firewall_endpoint["xsiam_preprod_firewall_endpoint"])
  xsiam_firewall_secret   = each.key == "live_data" ? tostring(local.firehose_prod_firewall_secret["xsiam_prod_firewall_secret"]) : tostring(local.firehose_preprod_firewall_secret["xsiam_preprod_firewall_secret"])

  # Tags
  tags_common = merge(
    local.tags,
    { inline-inspection = "true" }
  )
  tags_prefix = each.key
}