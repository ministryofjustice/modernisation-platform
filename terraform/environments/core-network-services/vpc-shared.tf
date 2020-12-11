locals {
  vpcs-shared = {
    sandbox-1 = {
      cidr = {
        vpc = "10.235.0.0/18"
        subnets = {
          tgw = [
            "10.235.48.0/28",
            "10.235.48.16/28",
            "10.235.48.32/28"
          ]
          private = [
            "10.235.0.0/21",
            "10.235.8.0/21",
            "10.235.16.0/21"
          ]
          public = [
            "10.235.24.0/22",
            "10.235.28.0/22",
            "10.235.32.0/22"
          ]
          data-persistence = [
            "10.235.36.0/22",
            "10.235.40.0/22",
            "10.235.44.0/22"
          ]
        }
      }
    }
    shared-1 = {
      cidr = {
        vpc = "10.235.64.0/18"
        subnets = {
          tgw = [
            "10.235.112.0/28",
            "10.235.112.16/28",
            "10.235.112.32/28"
          ]
          private = [
            "10.235.64.0/21",
            "10.235.72.0/21",
            "10.235.80.0/21"
          ]
          public = [
            "10.235.88.0/22",
            "10.235.92.0/22",
            "10.235.96.0/22"
          ]
          data-persistence = [
            "10.235.100.0/22",
            "10.235.104.0/22",
            "10.235.108.0/22"
          ]
        }
      }
    }
  }
  useful_vpc_ids-shared = {
    for key in keys(local.vpcs-shared) :
    key => {
      vpc_id                 = module.vpc-shared[key].vpc_id
      private_tgw_subnet_ids = module.vpc-shared[key].tgw_subnet_ids
    }
  }
}

module "vpc-shared" {
  for_each = local.vpcs-shared
  source   = "../../modules/core-vpc"

  # CIDRs
  subnet_cidrs_by_type = local.vpcs-shared[each.key].cidr.subnets
  vpc_cidr             = local.vpcs-shared[each.key].cidr.vpc

  # NAT Gateway
  enable_nat_gateway = false

  # Transit Gateway ID
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  shared_resource = true

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachments-shared-vpcs" {
  for_each = toset(keys(local.vpcs-shared))

  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = local.useful_vpc_ids-shared[each.value].vpc_id
  subnet_ids         = local.useful_vpc_ids-shared[each.value].private_tgw_subnet_ids

  # Turn off default route table association and propogation, as we're providing our own
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "enable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  tags = merge(
    local.tags,
    {
      Name = each.value
    },
  )
}
