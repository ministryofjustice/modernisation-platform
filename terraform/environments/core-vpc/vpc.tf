locals {
  # Get all VPC definitions by type
  vpcs = {
    # VPCs that sit within the core-vpc-production account
    core-vpc-production = {
      for file in fileset("subnet-sets", "*-production.json") :
      replace(file, ".json", "") => jsondecode(file("subnet-sets/${file}"))
    }
    # VPCs that sit within the core-vpc-non-live-data account
    core-vpc-non-live-data = {
      for file in fileset("subnet-sets", "*-non-live-data.json") :
      replace(file, ".json", "") => jsondecode(file("subnet-sets/${file}"))
    }
    # VPCs that sit within the core-vpc-pre-production account
    # core-vpc-pre-production = {
    #   for file in fileset("vpcs", "*-pre-production.json") :
    #     replace(file, ".json", "") => jsondecode(file("env/${file}"))
    # }

  }
}

output "vpcs" {
  value = local.vpcs
}

module "vpc" {
  providers = {
    aws                       = aws
    aws.core-network-services = aws.core-network-services
  }

  for_each = local.vpcs[terraform.workspace]

  source = "../../modules/member-vpc"

  subnet_sets = each.value.cidr.subnet_sets
  vpc_cidr    = each.value.cidr.transit_gateway

  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id
  # # CIDRs
  # subnet_cidrs_by_type = each.value.cidr.subnets
  # vpc_cidr             = each.value.cidr.vpc

  # # NACL rules
  # nacl_ingress = each.value.nacl.ingress
  # nacl_egress  = each.value.nacl.egress

  # # NAT Gateway
  # enable_nat_gateway = false

  # Tags
  tags_common = local.tags
  tags_prefix = each.key

}

module "vpc_tgw_routing" {
  source = "../../modules/vpc-tgw-routing"

  for_each = local.vpcs[terraform.workspace]

  providers = {
    aws                       = aws
    aws.core-network-services = aws.core-network-services
  }

  subnet_sets        = each.value.cidr.subnet_sets
  tgw_vpc_attachment = module.vpc_attachment[each.key].tgw_vpc_attachment
  tgw_route_table    = module.vpc_attachment[each.key].tgw_route_table
  tgw_id             = data.aws_ec2_transit_gateway.transit-gateway.id

  depends_on = [module.vpc_attachment, module.vpc]
}

module "vpc_nacls" {
  source = "../../modules/vpc-nacls"

  for_each = local.vpcs[terraform.workspace]

  nacl_config = each.value.nacl
  nacl_refs   = module.vpc[each.key].nacl_refs

  tags_common = local.tags
  tags_prefix = each.key

}


# output "nacl_refs" {
#   value = module.vpc["hmpps-production"].nacl_refs
# }

# output "debug" {
#   value = module.vpc["hmpps-production"].debug
# }
# output "expanded_worker_subnets_assocation" {
#   value = module.vpc["hmpps-production"].expanded_worker_subnets_assocation
# }
# output "expanded_worker_subnets_with_keys" {
#   value = module.vpc["hmpps-production"].expanded_worker_subnets_with_keys
# }
