# This additional CIDR and associated resources should be deleted once 10.20.0.0/16 is advertised internally
data "aws_availability_zones" "available" {}

locals {
  additional_subnet_cidr_map = {
    for az in data.aws_availability_zones.available.names :
    az => cidrsubnet(aws_vpc_ipv4_cidr_block_association.live-data-additional.cidr_block, 3, index(data.aws_availability_zones.available.names, az))
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "live-data-additional" {
  cidr_block = "10.26.144.0/21"
  vpc_id     = module.vpc["live_data"].vpc_id
}

resource "aws_subnet" "live-data-additional" {
  for_each   = local.additional_subnet_cidr_map
  cidr_block = each.value
  vpc_id     = module.vpc["live_data"].vpc_id
  tags       = local.tags
}

resource "aws_route_table" "live-data-additional" {
  vpc_id = module.vpc["live_data"].vpc_id
}

resource "aws_route_table_association" "live-data-additional" {
  for_each       = aws_subnet.live-data-additional
  route_table_id = aws_route_table.live-data-additional.id
  subnet_id      = each.value["id"]
}

resource "aws_route" "default-via-tgw" {
  route_table_id         = aws_route_table.live-data-additional.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.transit-gateway.id
}