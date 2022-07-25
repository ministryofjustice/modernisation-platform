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

  # To extend the below two data sections, just add additional lines with name and CIDR address to the relevant sections
  egress_pttp_routing_cidrs_non_live_data = {
    "global-protect"  = "10.184.0.0/16",
    "azure-noms-test" = "10.101.0.0/16",
    "cloud-platform"  = "172.20.0.0/16"
  }
  egress_pttp_routing_cidrs_live_data = {
    "global-protect"       = "10.184.0.0/16",
    "azure-noms-test"      = "10.101.0.0/16",
    "azure-noms-mgmt-live" = "10.40.128.0/20",
    "cloud-platform"       = "172.20.0.0/16",
    "ppud-psn"             = "51.247.0.0/16",
    "azure-noms-live"      = "10.40.0.0/18"
  }
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

  lifecycle {
    prevent_destroy = true
  }
}

######################
# TGW Route tables
######################
# Create Transit Gateway external-inspection-in routing table
resource "aws_ec2_transit_gateway_route_table" "external_inspection_in" {
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  tags = merge(
    local.tags,
    {
      Name = "external-inspection-in"
    }
  )
}
# Create Transit Gateway external-inspection-out routing table
resource "aws_ec2_transit_gateway_route_table" "external_inspection_out" {
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  tags = merge(
    local.tags,
    {
      Name = "external-inspection-out"
    }
  )
}

data "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_live_data" {
  for_each = toset(local.live_tgw_vpc_attachments)
  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

data "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_non_live_data" {
  for_each = toset(local.non_live_tgw_vpc_attachments)
  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

data "aws_ec2_transit_gateway_vpc_attachments" "transit_gateway_all" {}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_live_data" {
  for_each = data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_live_data
  transit_gateway_attachment_id  = each.value["id"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_non_live_data" {
  for_each = data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_non_live_data
  transit_gateway_attachment_id  = each.value["id"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate-firewall" {
  for_each = data.aws_ec2_transit_gateway_vpc_attachments.transit_gateway_all
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate-hmpps-test" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.hmpps-test.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate-hmpps-prod" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.hmpps-production.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# add external egress routes for non-live-data TGW route table to PTTP attachment
resource "aws_ec2_transit_gateway_route" "tgw_external_egress_routes_for_non_live_data_to_PTTP" {
  for_each = local.egress_pttp_routing_cidrs_non_live_data

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = local.pttp_production_transit_gateway_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}
# add external egress routes for live-data TGW route table to PTTP attachment
resource "aws_ec2_transit_gateway_route" "tgw_external_egress_routes_for_live_data_to_PTTP" {
  for_each = local.egress_pttp_routing_cidrs_live_data

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = local.pttp_production_transit_gateway_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

resource "aws_ec2_transit_gateway_route" "external_ingress_in_to_inspection_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.external_inspection_in.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# associate tgw external-inspection-in routing table with PTTP peering attachment
resource "aws_ec2_transit_gateway_route_table_association" "external_inspection_in" {
  transit_gateway_attachment_id  = local.pttp_production_transit_gateway_attachment
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# associate tgw external-inspection-out routing table with external-inspection-in subnet
resource "aws_ec2_transit_gateway_route_table_association" "external_inspection_out" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.external_inspection_in.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}