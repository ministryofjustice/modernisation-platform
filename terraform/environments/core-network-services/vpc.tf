locals {
  vpcs = {
    live = {
      cidr = {
        vpc = "10.230.0.0/19"
        tgw = [
          "10.230.0.0/28",
          "10.230.0.16/28",
          "10.230.0.32/28"
        ]
        private = [
          "10.230.8.0/23",
          "10.230.10.0/23",
          "10.230.12.0/23"
        ]
        public = [
          "10.230.2.0/23",
          "10.230.4.0/23",
          "10.230.6.0/23"
        ]
      }
    }
    non_live = {
      cidr = {
        vpc = "10.230.32.0/19"
        tgw = [
          "10.230.32.0/28",
          "10.230.32.16/28",
          "10.230.32.32/28"
        ]
        private = [
          "10.230.40.0/23",
          "10.230.42.0/23",
          "10.230.44.0/23"
        ]
        public = [
          "10.230.34.0/23",
          "10.230.36.0/23",
          "10.230.38.0/23"
        ]
      }
    }
  }
}
module "vpc" {
  for_each            = local.vpcs
  source              = "../../modules/core-vpc"
  vpc_cidr            = local.vpcs[each.key].cidr.vpc
  tgw_cidr_blocks     = local.vpcs[each.key].cidr.tgw
  private_cidr_blocks = local.vpcs[each.key].cidr.private
  public_cidr_blocks  = local.vpcs[each.key].cidr.public
  tags_common         = local.tags
  tags_prefix         = each.key
}
