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

  pttp_production_transit_gateway_attachment = "tgw-attach-08374a4bae2939acb"

  # hmpps_general_development_subnet_set_cidr   = local.vpcs.core-vpc-development.hmpps-development.cidr.subnet_sets.general.cidr
  hmpps_general_test_subnet_set_cidr = local.vpcs.core-vpc-test.hmpps-test.cidr.subnet_sets.general.cidr
  # hmpps_general_preproduction_subnet_set_cidr = local.vpcs.core-vpc-preproduction.hmpps-preproduction.cidr.subnet_sets.general.cidr
  # hmpps_general_production_subnet_set_cidr    = local.vpcs.core-vpc-production.hmpps-production.cidr.subnet_sets.general.cidr
  global_protect_cidr = "10.184.0.0/16"

}

################
# TGW Peering  #
################

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "PTTP-Production" {

  transit_gateway_attachment_id = local.pttp_production_transit_gateway_attachment
  tags = {
    Name = "PTTP-Transit-Gateway-attachment-accepter"
    Side = "Acceptor"
  }
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
  transit_gateway_attachment_id  = local.pttp_production_transit_gateway_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}
resource "aws_ec2_transit_gateway_route" "tgw_egress_routing_live_data_to_global_protect" {
  destination_cidr_block         = local.global_protect_cidr
  transit_gateway_attachment_id  = local.pttp_production_transit_gateway_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

# associate mp tgw routing table to routing vpc attachment
resource "aws_ec2_transit_gateway_route_table_association" "mp_routing_tgw-non-live-data" {
  transit_gateway_attachment_id  = local.pttp_production_transit_gateway_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.pttp_ingress.id
}
