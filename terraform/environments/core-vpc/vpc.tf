locals {
  # Get all VPC definitions by type
  vpcs = {
    # VPCs that sit within the core-vpc-production account
    core-vpc-production = {
      for file in fileset("vpcs", "*-production.json") :
      replace(file, ".json", "") => jsondecode(file("vpcs/${file}"))
    }
    # VPCs that sit within the core-vpc-non-live-data account
    core-vpc-non-live-data = {
      for file in fileset("vpcs", "*-non-live-data.json") :
      replace(file, ".json", "") => jsondecode(file("vpcs/${file}"))
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

  source = "../../modules/core-vpc"

  # CIDRs
  subnet_cidrs_by_type = each.value.cidr.subnets
  vpc_cidr             = each.value.cidr.vpc

  # NACL rules
  nacl_ingress = each.value.nacl.ingress
  nacl_egress  = each.value.nacl.egress

  # NAT Gateway
  enable_nat_gateway = false

  # Tags
  tags_common = {}
  tags_prefix = each.key
}
