locals {
  # useful_vpc_ids = {
  #   for key in keys(local.vpcs) :
  #   key => {
  #     vpc_id                 = module.vpc[key].vpc_id
  #     private_tgw_subnet_ids = module.vpc[key].tgw_subnet_ids
  #   }
  # }

  network = {
    live_data = {
      cidr = "10.231.0.0/19"
    }
    non_live_data = {
      cidr = "10.231.32.0/19"
    }
  }

}

module "vpc" {
  for_each = local.network
  source   = "../../modules/core-vpc"

  # CIDRs
  vpc_cidr = local.network[each.key].cidr

  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id

  # private gateway type
  #   nat = Nat Gateway
  #   transit = Transit Gateway
  #   none = no gateway for internal traffic
  gateway = "transit"

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}
