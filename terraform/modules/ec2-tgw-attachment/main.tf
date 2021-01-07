provider "aws" {
  alias = "core-network-services"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "live_data" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id

  # transit_gateway_default_route_table_association = false
  # transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "terraform-example"
    Side = "Creator"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "live_data" {
  provider = aws.core-network-services

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.live_data.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.live_data.id
}

data "aws_ec2_transit_gateway_route_table" "live_data" {
  provider = aws.core-network-services
  filter {
    name   = "tag:Name"
    values = ["live_data"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [var.tgw_id]
  }
}
