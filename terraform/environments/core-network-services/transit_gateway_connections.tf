######################
# Do data lookups
######################
# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}
# Get TGW attachment id for HMPPS
data "aws_ec2_transit_gateway_vpc_attachment" "hmpps-development" {

  filter {
    name   = "tag:Name"
    values = ["hmpps-development-attachment"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "hmpps-test" {

  filter {
    name   = "tag:Name"
    values = ["hmpps-test-attachment"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "hmpps-preproduction" {

  filter {
    name   = "tag:Name"
    values = ["hmpps-preproduction-attachment"]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "hmpps-production" {

  filter {
    name   = "tag:Name"
    values = ["hmpps-production-attachment"]
  }
}
locals {

  # Get all VPC definitions by type
  vpcs = {
    # VPCs that sit within the core-vpc-production account
    core-vpc-production = {
      for file in fileset("../../../environments-networks", "*-production.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }

    core-vpc-preproduction = {
      for file in fileset("../../../environments-networks", "*-preproduction.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }

    # VPCs that sit within the core vpc test account
    core-vpc-test = {
      for file in fileset("../../../environments-networks", "*-test.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }

    # VPCs that sit within the core vpc development account
    core-vpc-development = {
      for file in fileset("../../../environments-networks", "*-development.json") :
      replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
    }
  }
  availability_zones = sort(data.aws_availability_zones.available.names)

  pttp_production_transit_gateway = "tgw-026162f1ba39ce704"

  routing_vpc1              = "10.56.0.0/20"
  routing_vpc1_pttp_subnets = "10.56.0.0/26"
  routing_vpc1_mp_subnets   = "10.56.0.128/26"

  routing_vpc1_pttp_subnets_map = { for key, cidr in cidrsubnets(local.routing_vpc1_pttp_subnets, 2, 2, 2) : local.availability_zones[key] => cidr }
  routing_vpc1_mp_subnets_map   = { for key, cidr in cidrsubnets(local.routing_vpc1_mp_subnets, 2, 2, 2) : local.availability_zones[key] => cidr }

  # hmpps_general_development_subnet_set_cidr   = local.vpcs.core-vpc-development.hmpps-development.cidr.subnet_sets.general.cidr
  hmpps_general_test_subnet_set_cidr = local.vpcs.core-vpc-test.hmpps-test.cidr.subnet_sets.general.cidr
  # hmpps_general_preproduction_subnet_set_cidr = local.vpcs.core-vpc-preproduction.hmpps-preproduction.cidr.subnet_sets.general.cidr
  # hmpps_general_production_subnet_set_cidr    = local.vpcs.core-vpc-production.hmpps-production.cidr.subnet_sets.general.cidr
  global_protect_cidr = "10.180.92.0/22"

  tgw_routing_pttp_routes = {
    "${local.global_protect_cidr}" = local.pttp_production_transit_gateway,
    # "${local.hmpps_general_development_subnet_set_cidr}" = aws_ec2_transit_gateway.transit-gateway.id,
    "${local.hmpps_general_test_subnet_set_cidr}" = aws_ec2_transit_gateway.transit-gateway.id
    # "${local.hmpps_general_preproduction_subnet_set_cidr}" = aws_ec2_transit_gateway.transit-gateway.id,
    # "${local.hmpps_general_production_subnet_set_cidr}" = aws_ec2_transit_gateway.transit-gateway.id,
  }
}
#################
# VPC creation #
#################
# Routing VPC
resource "aws_vpc" "tgw_routing_1" {
  #checkov:skip=CKV2_AWS_12:This vpc is for tgw routing only, the default only allows known routing cidrs

  cidr_block = local.routing_vpc1

  # Instance Tenancy
  instance_tenancy = "default"
  # DNS
  enable_dns_support   = false
  enable_dns_hostnames = false
  # ClassicLink
  enable_classiclink             = false
  enable_classiclink_dns_support = false
  # Turn off IPv6
  assign_generated_ipv6_cidr_block = false

  tags = merge(
    local.tags,
    {
      Name = "tgw-routing"
    }
  )
}

resource "aws_default_security_group" "tgw_routing_1" {
  vpc_id = aws_vpc.tgw_routing_1.id

  tags = merge(
    local.tags,
    {
      Name = "tgw-routing"
    }
  )
}

resource "aws_security_group_rule" "tgw_routing_1_ingress" {
  for_each = local.tgw_routing_pttp_routes

  description       = "rules for ingress routing traffic"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = [each.key]
  security_group_id = aws_default_security_group.tgw_routing_1.id
}

resource "aws_security_group_rule" "tgw_routing_1_egress" {
  for_each = local.tgw_routing_pttp_routes

  description       = "rules for egress routing traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = [each.key]
  security_group_id = aws_default_security_group.tgw_routing_1.id
}

#################
# VPC Flow Logs #
#################
# TF sec exclusions
# - Ignore warnings regarding log groups not encrypted using customer-managed KMS keys - following cost/benefit discussion and longer term plans for logging solution
#tfsec:ignore:AWS089
resource "aws_cloudwatch_log_group" "tgw_routing_vpc" {
  #checkov:skip=CKV_AWS_158:Temporarily skip KMS encryption check while logging solution is being updated
  name              = "tgw-routing-vpc-1-flow-logs"
  retention_in_days = 365 # 0 = never expire
  tags              = local.tags
}

resource "aws_flow_log" "tgw-routing_vpc" {
  iam_role_arn             = data.aws_iam_role.vpc-flow-log.arn
  log_destination          = aws_cloudwatch_log_group.tgw_routing_vpc.arn
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  max_aggregation_interval = "60"
  vpc_id                   = aws_vpc.tgw_routing_1.id

  tags = merge(
    local.tags,
    {
      Name = "tgw-routing-vpc-flow-logs"
    }
  )
}

######################
# Routing Subnets
######################
# Create pttp side subnets
resource "aws_subnet" "pttp_side_tgw_routing" {
  for_each = local.routing_vpc1_pttp_subnets_map

  vpc_id = aws_vpc.tgw_routing_1.id

  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    local.tags,
    {
      Name = "tgw-routing-subnet-pttp-side-${each.key}"
    }
  )
}

# Create mp side subnets
resource "aws_subnet" "mp_side_tgw_routing" {
  for_each = local.routing_vpc1_mp_subnets_map

  vpc_id = aws_vpc.tgw_routing_1.id

  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    local.tags,
    {
      Name = "tgw-routing-subnet-mp-side-${each.key}"
    }
  )
}

######################
# VPC Routing
######################
resource "aws_route_table" "tgw_routing_1" {
  vpc_id = aws_vpc.tgw_routing_1.id

  tags = merge(
    local.tags,
    {
      Name = "tgw_routing_1"
    }
  )
}

# attach subnets to vpc routing table
resource "aws_route_table_association" "pttp_routing_subnet" {
  for_each = toset(local.availability_zones)

  subnet_id      = aws_subnet.pttp_side_tgw_routing[each.value].id
  route_table_id = aws_route_table.tgw_routing_1.id
}
resource "aws_route_table_association" "mp_routing_subnet" {
  for_each = toset(local.availability_zones)

  subnet_id      = aws_subnet.mp_side_tgw_routing[each.value].id
  route_table_id = aws_route_table.tgw_routing_1.id
}


resource "aws_route" "tgw_routing_1_routes" {
  for_each = local.tgw_routing_pttp_routes

  route_table_id         = aws_route_table.tgw_routing_1.id
  destination_cidr_block = each.key
  transit_gateway_id     = each.value
}

######################
# TGW Route tables
######################
# Create Transit Gateway PTTP ingress routing table
resource "aws_ec2_transit_gateway_route_table" "pttp_ingress" {
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  tags = merge(
    local.tags,
    {
      Name = "pttp ingress"
    }
  )
}
# add ingress routes for hmpps to pttp ingress tgw route table
# resource "aws_ec2_transit_gateway_route" "tgw_pttp_ingress_routing_to_hmpps_development" {
#   destination_cidr_block         = local.hmpps_general_development_subnet_set_cidr
#   transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.hmpps-development.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pttp_ingress.id
# }
resource "aws_ec2_transit_gateway_route" "tgw_pttp_ingress_routing_to_hmpps_test" {
  destination_cidr_block         = local.hmpps_general_test_subnet_set_cidr
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.hmpps-test.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pttp_ingress.id
}
# resource "aws_ec2_transit_gateway_route" "tgw_pttp_ingress_routing_to_hmpps_preproduction" {
#   destination_cidr_block         = local.hmpps_general_preproduction_subnet_set_cidr
#   transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.hmpps-preproduction.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pttp_ingress.id
# }
# resource "aws_ec2_transit_gateway_route" "tgw_pttp_ingress_routing_to_hmpps_production" {
#   destination_cidr_block         = local.hmpps_general_production_subnet_set_cidr
#   transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.hmpps-production.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pttp_ingress.id
# }
# add egress routes for global protect for non-prod-data and prod-data tgw route tables
resource "aws_ec2_transit_gateway_route" "tgw_egress_routing_non_live_data_to_global_protect" {
  destination_cidr_block         = local.global_protect_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mp_side_routing.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}
resource "aws_ec2_transit_gateway_route" "tgw_egress_routing_live_data_to_global_protect" {
  destination_cidr_block         = local.global_protect_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mp_side_routing.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}


###########################
# TGW attach routing vpc
###########################

# Attach routing VPC to the PTTP Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "pttp_side_routing" {

  transit_gateway_id = local.pttp_production_transit_gateway


  # Attach subnets to the Transit Gateway
  vpc_id = aws_vpc.tgw_routing_1.id
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.pttp_side_tgw_routing["${az}"].id
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "disable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  tags = merge(
    local.tags,
    {
      Name = "routing-pttp-side-transit-gateway"
    },
  )
}

# Attach routing VPC to the MP Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "mp_side_routing" {

  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  # Attach subnets to the Transit Gateway
  vpc_id = aws_vpc.tgw_routing_1.id
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.mp_side_tgw_routing["${az}"].id
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "disable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  tags = merge(
    local.tags,
    {
      Name = "routing-mp-side-transit-gateway"
    },
  )
}

# associate mp tgw routing table to routing vpc attachment
resource "aws_ec2_transit_gateway_route_table_association" "mp_routing_tgw-non-live-data" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mp_side_routing.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pttp_ingress.id
}
