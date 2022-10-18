######################
# Do data lookups
######################
# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ec2_transit_gateway_vpc_attachments" "transit_gateway_all" {}

data "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_all" {
  for_each = toset(data.aws_ec2_transit_gateway_vpc_attachments.transit_gateway_all.ids)
  id       = each.key
}

data "aws_ec2_transit_gateway_peering_attachment" "pttp-tgw" {
  filter {
    name   = "tag:Name"
    values = ["PTTP-Transit-Gateway-attachment-accepter"]
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

  # To extend the below two data sections, just add additional lines with name and CIDR address to the relevant sections
  egress_pttp_routing_cidrs_non_live_data = {
    "azure-noms-test"          = "10.101.0.0/16",
    "azure-noms-mgmt"          = "10.102.0.0/16",
    "azure-nomisapi-t3"        = "10.47.0.0/26",
    "azure-studiohosting-dev1" = "10.247.0.0/20",
    "azure-studiohosting-ops1" = "10.247.32.0/20",
    "global-protect"           = "10.184.0.0/16",
    "cloud-platform"           = "172.20.0.0/16",
    "laa-development"          = "10.202.0.0/20"
  }

  egress_pttp_routing_cidrs_live_data = {
    "azure-fixngo-live"         = "10.40.0.0/16",
    "azure-studiohosting-live1" = "10.244.0.0/20",
    "azure-nomisapi-preprod"    = "10.47.0.64/26",
    "azure-nomisapi-prod"       = "10.47.0.128/26",
    "global-protect"            = "10.184.0.0/16",
    "cloud-platform"            = "172.20.0.0/16",
    "ppud-psn"                  = "51.247.0.0/16",
  }

  tgw_live_data_attachments = {
    for k, v in data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_all : k => v.tags.Name if(
      length(regexall("(?:production-attachment)", v.tags.Name)) > 0 ||
      length(regexall("(?:preproduction-attachment)", v.tags.Name)) > 0 ||
      length(regexall("(?:-live_data-attachment)", v.tags.Name)) > 0
    )
  }

  tgw_non_live_data_attachments = {
    for k, v in data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_all : k => v.tags.Name if(
      length(regexall("(?:development-attachment)", v.tags.Name)) > 0 ||
      length(regexall("(?:test-attachment)", v.tags.Name)) > 0 ||
      length(regexall("(?:-non_live_data-attachment)", v.tags.Name)) > 0
    )
  }

}

################
# TGW Peering  #
################

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "PTTP-Production" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.pttp-tgw.id
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
# Create Transit Gateway route table for ingress via external (non-MP) locations
resource "aws_ec2_transit_gateway_route_table" "external_inspection_in" {
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
  tags = merge(
    local.tags,
    { Name = "external" }
  )
}
# Create Transit Gateway firewall VPC routing table
resource "aws_ec2_transit_gateway_route_table" "external_inspection_out" {
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
  tags = merge(
    local.tags,
    { Name = "firewall" }
  )
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_live_data_vpcs" {
  for_each                       = local.tgw_live_data_attachments
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_non_live_data_vpcs" {
  for_each                       = local.tgw_non_live_data_attachments
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_firewall" {
  for_each                       = data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_all
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

## Temporarily bypass MP NWFW
resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_external-in" {
  for_each                       = data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_all
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# add external egress routes for non-live-data TGW route table to PTTP attachment
resource "aws_ec2_transit_gateway_route" "tgw_external_egress_routes_for_non_live_data_to_PTTP" {
  for_each = local.egress_pttp_routing_cidrs_non_live_data

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.pttp-tgw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}

# add external egress routes for live-data TGW route table to PTTP attachment
resource "aws_ec2_transit_gateway_route" "tgw_external_egress_routes_for_live_data_to_PTTP" {
  for_each = local.egress_pttp_routing_cidrs_live_data

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.pttp-tgw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

resource "aws_ec2_transit_gateway_route" "external_ingress_in_to_inspection_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.external_inspection_in.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# associate tgw external-inspection-in routing table with PTTP peering attachment
resource "aws_ec2_transit_gateway_route_table_association" "external_inspection_in" {
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.pttp-tgw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# associate tgw external-inspection-out routing table with external-inspection-in subnet
resource "aws_ec2_transit_gateway_route_table_association" "external_inspection_out" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.external_inspection_in.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}