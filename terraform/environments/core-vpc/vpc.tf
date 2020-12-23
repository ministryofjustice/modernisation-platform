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

module "vpc" {
  for_each = local.vpcs[terraform.workspace]

  source = "../../modules/member-vpc"

  subnet_sets = each.value.cidr.subnet_sets
  vpc_cidr    = each.value.cidr.transit_gateway
  # # CIDRs
  # subnet_cidrs_by_type = each.value.cidr.subnets
  # vpc_cidr             = each.value.cidr.vpc

  # # NACL rules
  # nacl_ingress = each.value.nacl.ingress
  # nacl_egress  = each.value.nacl.egress

  # # NAT Gateway
  # enable_nat_gateway = false

  # Tags
  tags_common = {}
  tags_prefix = each.key

}

output "expanded_worker_subnets" {
  value = module.vpc["hmpps-production"].expanded_worker_subnets
}
# output "expanded_worker_subnets_assocation" {
#   value = module.vpc["hmpps-production"].expanded_worker_subnets_assocation
# }
# output "expanded_worker_subnets_with_keys" {
#   value = module.vpc["hmpps-production"].expanded_worker_subnets_with_keys
# }
