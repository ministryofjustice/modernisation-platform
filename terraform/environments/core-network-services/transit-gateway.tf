#########################
# Create Transit Gateway
#########################
resource "aws_ec2_transit_gateway" "transit-gateway" {
  description = "Managed by Terraform"

  amazon_side_asn                 = "64589"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(
    local.tags,
    {
      Name = "Modernisation Platform: Transit Gateway"
    },
  )

  lifecycle {
    prevent_destroy = true
  }
}

#########################
# Attach VPCs to the Transit Gateway
#########################
resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each = local.networking

  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  # Attach VPC and private subnets to the Transit Gateway
  vpc_id     = local.useful_vpc_ids[each.key].vpc_id
  subnet_ids = local.useful_vpc_ids[each.key].private_tgw_subnet_ids

  # Turn off default route table association and propogation, as we're providing our own
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "enable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  tags = merge(
    local.tags,
    { "Name" = format("%s-%s-attachment", local.application_name, each.key) }
  )

  lifecycle {
    prevent_destroy = true
  }
}

## Inline-inspection attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "attachments-inspection" {
  for_each = local.networking
  appliance_mode_support = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
  vpc_id             = module.vpc_inspection[each.key].vpc_id
  subnet_ids {
    module.vpc-inspection[each.key].subnet_attributes.transit-gateway.*.id
  }
}

#########################
# Route table and routes
#########################
# Create a route table for each VPC attachment
resource "aws_ec2_transit_gateway_route_table" "route-tables" {
  for_each = local.networking

  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  tags = merge(
    local.tags,
    {
      Name = each.key
    },
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Associate the route table with the VPC attachment
resource "aws_ec2_transit_gateway_route_table_association" "association" {
  for_each = local.networking

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables[each.key].id
}

#########################
# Routes for VPC attachments
#########################
resource "aws_ec2_transit_gateway_route" "nat_route" {
  for_each = local.networking

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables[each.key].id
}
