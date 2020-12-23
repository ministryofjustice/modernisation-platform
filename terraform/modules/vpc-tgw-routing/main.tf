provider "aws" {
  alias = "core-network-services"
}

resource "aws_ec2_transit_gateway_route" "example" {
  for_each = tomap(var.subnet_sets)

  provider = aws.core-network-services

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = var.tgw_vpc_attachment
  transit_gateway_route_table_id = var.tgw_route_table
}

data "aws_vpc" "selected" {
  provider = aws.core-network-services

  filter {
    name = "tag:Name"
    values = ["live"]
  }
}

data "aws_route_table" "live-public" {
  provider = aws.core-network-services

  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = ["live-public"]
  }
}

resource "aws_route" "test" {
  provider = aws.core-network-services

  for_each = tomap(var.subnet_sets)

  route_table_id = data.aws_route_table.live-public.id
  destination_cidr_block = each.value
  transit_gateway_id = var.tgw_id
}
