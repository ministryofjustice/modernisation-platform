locals {
  # Private TGW CIDR blocks for live
  private_tgw_cidr_blocks_live = [
    "10.230.0.0/28",
    "10.230.0.16/28",
    "10.230.0.32/28"
  ]
  # Private TGW CIDR blocks for non-live
  private_tgw_cidr_blocks_non_live = [
    "10.230.32.0/28",
    "10.230.32.16/28",
    "10.230.32.32/28"
  ]
}

# VPC: Live
module "vpc-live" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "live"
  cidr   = "10.230.0.0/19"
  azs    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

  create_vpc                = true
  instance_tenancy          = "default"
  enable_dns_hostnames      = true
  enable_dns_support        = true
  enable_nat_gateway        = true
  single_nat_gateway        = false
  one_nat_gateway_per_az    = true
  enable_public_s3_endpoint = true

  # We should probably move default VPC management outside of this
  manage_default_vpc = true
  default_vpc_name   = "default-vpc-do-not-use"

  # Public subnets
  public_subnets = [
    "10.230.2.0/23",
    "10.230.4.0/23",
    "10.230.6.0/23"
  ]
  public_subnet_suffix = "public"

  private_subnets = concat([
    "10.230.8.0/23",
    "10.230.10.0/23",
    "10.230.12.0/23"
  ], local.private_tgw_cidr_blocks_live)
  private_subnet_suffix = "private"

  # IPv6
  enable_ipv6                                    = false
  public_subnet_assign_ipv6_address_on_creation  = false
  private_subnet_assign_ipv6_address_on_creation = false

  tags = local.tags
}

module "vpc-non-live" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "non-live"
  cidr   = "10.230.32.0/19"
  azs    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

  create_vpc                = true
  instance_tenancy          = "default"
  enable_dns_hostnames      = true
  enable_dns_support        = true
  enable_nat_gateway        = true
  single_nat_gateway        = false
  one_nat_gateway_per_az    = true
  enable_public_s3_endpoint = true

  # manage_default_vpc = true
  # default_vpc_name   = "default-vpc-do-not-use"

  # Public subnets
  public_subnets = [
    "10.230.34.0/23",
    "10.230.36.0/23",
    "10.230.38.0/23"
  ]
  public_subnet_suffix = "public"

  private_subnets = concat([
    "10.230.40.0/23",
    "10.230.42.0/23",
    "10.230.44.0/23"
  ], local.private_tgw_cidr_blocks_non_live)
  private_subnet_suffix = "private"

  # IPv6
  enable_ipv6                                    = false
  public_subnet_assign_ipv6_address_on_creation  = false
  private_subnet_assign_ipv6_address_on_creation = false

  tags = local.tags
}

# Get subnets after creation
# Live
data "aws_subnet_ids" "subnets-live" {
  vpc_id = module.vpc-live.vpc_id
}

data "aws_subnet" "subnet-live" {
  for_each = data.aws_subnet_ids.subnets-live.ids
  id       = each.value
}

# Non-live
data "aws_subnet_ids" "subnets-non-live" {
  vpc_id = module.vpc-non-live.vpc_id
}

data "aws_subnet" "subnet-non-live" {
  for_each = data.aws_subnet_ids.subnets-non-live.ids
  id       = each.value
}
