provider "aws" {
  alias = "core-network-services"
}

# Attach provided subnet IDs and VPC to the provided Transit Gateway ID
resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id

  appliance_mode_support = "disable"
  dns_support            = "enable"
  ipv6_support           = "disable"

  # You can't change these with a RAM-shared Transit Gateway, but we'll
  # leave them here to be explicit.
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(var.tags, {
    Name = "shared-transit-gateway-attachment"
  })
}

# Look up route tables to associate with
data "aws_ec2_transit_gateway_route_table" "default" {
  provider = aws.core-network-services

  filter {
    name   = "tag:Name"
    values = [var.type]
  }

  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }
}

# Associate the Transit Gateway Route Table with the VPC
resource "aws_ec2_transit_gateway_route_table_association" "default" {
  provider = aws.core-network-services

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.default.id
}
