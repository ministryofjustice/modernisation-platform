locals {
  networking = {
    live_data     = "10.230.0.0/19"
    non_live_data = "10.230.32.0/19"
  }
}

locals {
  useful_vpc_ids = {
    for key in keys(local.networking) :
    key => {
      vpc_id                 = module.vpc[key].vpc_id
      private_tgw_subnet_ids = module.vpc[key].tgw_subnet_ids
    }
  }
}

module "vpc" {
  for_each = local.networking
  source   = "../../modules/core-vpc"

  # CIDRs
  vpc_cidr = each.value

  # private gateway type
  #   nat = Nat Gateway
  #   transit = Transit Gateway
  #   none = no gateway for internal traffic
  gateway = "nat"

  # VPC Flow Logs
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}
