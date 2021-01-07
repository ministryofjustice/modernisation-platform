#########################
# Create TGW
#########################
resource "aws_ec2_transit_gateway" "transit-gateway" {
  description                     = "ModernisationPlatform Transit Gateway"
  amazon_side_asn                 = "64589"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"
  vpn_ecmp_support                = "enable"
  dns_support                     = "enable"
  tags = merge(
    local.tags,
    {
      Name = "TGW-ModernisationPlatform"
    },
  )
}

#########################
# Route table and routes
#########################
resource "aws_ec2_transit_gateway_route_table" "transit-gateway-route-table" {
  for_each = toset(keys(local.vpcs))

  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
  tags = merge(
    local.tags,
    {
      Name = each.value
    },
  )
}

#########################
# VPC attachment
#########################
resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each = toset(keys(local.vpcs))

  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id
  vpc_id             = local.useful_vpc_ids[each.value].vpc_id
  subnet_ids         = local.useful_vpc_ids[each.value].private_tgw_subnet_ids

  # Turn off default route table association and propogation, as we're providing our own
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Enable DNS support
  dns_support = "enable"

  # Turn off IPv6 support
  ipv6_support = "disable"

  tags = merge(
    local.tags,
    {
      Name = each.value
    },
  )
}

##########################
# Route table association
##########################
resource "aws_ec2_transit_gateway_route_table_association" "tables" {
  for_each = toset(keys(local.vpcs))

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit-gateway-route-table[each.value].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagation" {
  for_each = toset(keys(local.vpcs))

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit-gateway-route-table[each.value].id
}

resource "aws_ec2_transit_gateway_route" "nat_route" {
  for_each = toset(keys(local.vpcs))

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit-gateway-route-table[each.value].id
}
