locals {
  networking = {
    live_data     = "10.20.0.0/19"
    non_live_data = "10.20.32.0/19"
  }
}

module "vpc_hub" {
  for_each = local.networking

  source = "../../modules/vpc-hub"

  # CIDRs
  vpc_cidr = each.value

  # Private gateway type
  #   nat = NAT Gateway
  #   transit = Transit Gateway
  #   none = No gateway for internal traffic
  gateway = "nat"

  # VPC Flow Logs
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn

  # Transit Gateway ID
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

module "vpc_inspection" {
  for_each = local.networking

  source                = "../../modules/vpc-inspection"
  application_name      = local.application_name
  fw_allowed_domains    = local.fqdn_firewall_rules.fw_allowed_domains
  fw_home_net_ips       = local.fqdn_firewall_rules.fw_home_net_ips
  fw_rules              = local.inline_firewall_rules
  vpc_cidr              = each.value
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn
  transit_gateway_id    = aws_ec2_transit_gateway.transit-gateway.id

  # Tags
  tags_common = merge(
    local.tags,
    { inline-inspection = "true" }
  )
  tags_prefix = each.key
}