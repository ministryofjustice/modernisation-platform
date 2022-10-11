locals {
  networking = {
    live_data     = "10.20.0.0/19"
    non_live_data = "10.20.32.0/19"
  }

  useful_vpc_ids = {
    for key in keys(local.networking) :
    key => {
      vpc_id                 = module.vpc_hub[key].vpc_id
      private_tgw_subnet_ids = module.vpc_hub[key].tgw_subnet_ids
    }
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