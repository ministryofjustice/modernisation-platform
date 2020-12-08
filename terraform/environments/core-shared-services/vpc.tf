locals {
  vpcs = {
    live = {
      cidr = {
        vpc = "10.231.0.0/19"
        subnets = {
          tgw = [
            "10.231.0.16/28",
            "10.231.0.32/28",
            "10.231.0.64/28"
          ]
          private = [
            "10.231.8.0/23",
            "10.231.10.0/23",
            "10.231.12.0/23"
          ]
          public = [
            "10.231.2.0/23",
            "10.231.4.0/23",
            "10.231.6.0/23"
          ]
        }
      }
    }
    non_live = {
      cidr = {
        vpc = "10.231.32.0/19"
        subnets = {
          tgw = [
            "10.231.32.0/28",
            "10.231.32.16/28",
            "10.231.32.32/28"
          ]
          private = [
            "10.231.40.0/23",
            "10.231.42.0/23",
            "10.231.44.0/23"
          ]
          public = [
            "10.231.34.0/23",
            "10.231.36.0/23",
            "10.231.38.0/23"
          ]
        }
      }
    }
  }

  useful_vpc_ids = {
    for key in keys(local.vpcs) :
    key => {
      vpc_id                 = module.vpc[key].vpc_id
      private_tgw_subnet_ids = module.vpc[key].tgw_subnet_ids
    }
  }
}

module "vpc" {
  for_each = local.vpcs
  source   = "../../modules/core-vpc"

  # CIDRs
  subnet_cidrs_by_type = local.vpcs[each.key].cidr.subnets
  vpc_cidr             = local.vpcs[each.key].cidr.vpc

  # NAT Gateway
  enable_nat_gateway = false

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}
