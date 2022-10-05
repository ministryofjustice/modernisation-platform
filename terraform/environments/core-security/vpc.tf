locals {
  networking = {
    live_data     = "10.20.192.0/19"
    non_live_data = "10.20.224.0/19"
  }
}

module "vpc" {
  for_each = local.networking
  source   = "../../modules/vpc-hub"

  # CIDRs
  vpc_cidr = each.value

  # private gateway type
  #   nat = Nat Gateway
  #   transit = Transit Gateway
  #   none = no gateway for internal traffic
  gateway = "transit"

  # VPC Flow Logs
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

module "core-vpc-tgw-routes" {
  for_each = local.networking
  source   = "../../modules/core-vpc-tgw-routes"

  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id
  route_table_ids    = module.vpc[each.key].private_route_tables

  depends_on = [module.vpc_attachment]
}
