locals {
  remote_transit_gateway = "tgw-1111111111111111"
}

# Routing VPC
resource "aws_vpc" "tgw_routing" {
  cidr_block = "10.230.64.0/19"

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
      Name = "routing-vpc"
    }
  )
}

# Create remote side routing table and subnet
resource "aws_subnet" "remote_side_routing" {

  vpc_id = aws_vpc.tgw_routing.id

  cidr_block        = "10.230.64.0/25"
  availability_zone = "eu-west-2a"

  tags = merge(
    local.tags,
    {
      Name = "routing-subnet-remote-side"
    }
  )
}
resource "aws_route_table" "remote_side" {
  vpc_id = aws_vpc.tgw_routing.id

  route {
    cidr_block = "10.234.0.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
  }

  tags = merge(
    local.tags,
    {
      Name = "routing-remote-side"
    }
  )
}
resource "aws_route_table_association" "remote_side" {
  subnet_id      = aws_subnet.remote_side_routing.id
  route_table_id = aws_route_table.remote_side.id
}


# Create MP side routing table and subnet
resource "aws_subnet" "local_side_routing" {

  vpc_id = aws_vpc.tgw_routing.id

  cidr_block        = "10.230.64.128/25"
  availability_zone = "eu-west-2a"

  tags = merge(
    local.tags,
    {
      Name = "routing-subnet-local_side"
    }
  )
}
resource "aws_route_table" "local_side" {
  vpc_id = aws_vpc.tgw_routing.id

  route {
    cidr_block = "10.239.0.0/16"
    transit_gateway_id = local.remote_transit_gateway
  }

  tags = merge(
    local.tags,
    {
      Name = "routing-local-side"
    }
  )
}
resource "aws_route_table_association" "local_side" {
  subnet_id      = aws_subnet.local_side_routing.id
  route_table_id = aws_route_table.local_side.id
}


# Attach routing VPC to the MOJ Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "remote_side_routing" {

  transit_gateway_id = local.remote_transit_gateway


  # Attach VPC and private subnets to the Transit Gateway
  vpc_id     = aws_vpc.tgw_routing.id
  subnet_ids = [ aws_subnet.remote_side_routing.id ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "disable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  tags = merge(
    local.tags,
    {
      Name = "routing-remote-side-transit-gateway"
    },
  )
}
resource "aws_ec2_transit_gateway_route_table_association" "mp_routing_tgw" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.local_side_routing.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}
resource "aws_ec2_transit_gateway_route" "local_side_routing_to_remote_side" {
  destination_cidr_block         = "10.239.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.local_side_routing.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
}




# Attach routing VPC to the local Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "local_side_routing" {

  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
                        
  # Attach VPC and private subnets to the Transit Gateway
  vpc_id     = aws_vpc.tgw_routing.id
  subnet_ids = [ aws_subnet.local_side_routing.id ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "disable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  tags = merge(
    local.tags,
    {
      Name = "routing-local-side-transit-gateway"
    },
  )
}