#########################
# Create TGW
#########################
resource "aws_ec2_transit_gateway" "TGW" {
  description                     = "ModernisationPlatform Transit Gateway"
  amazon_side_asn                 = "64589"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "disable"
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
resource "aws_ec2_transit_gateway_route_table" "TGW_route_table" {
  for_each = toset(keys(local.vpcs))

  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
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
locals {
  created_vpcs_ids = {
    live     = module.vpc["live"].vpc_id
    non_live = module.vpc["non_live"].vpc_id
  }
  created_private_tgw_subnet_ids = {
    live     = module.vpc["live"].tgw_subnet_ids
    non_live = module.vpc["non_live"].tgw_subnet_ids
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each = toset(keys(local.vpcs))

  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = local.created_vpcs_ids[each.value]
  subnet_ids         = local.created_private_tgw_subnet_ids[each.value]

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
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_route_table[each.value].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagation" {
  for_each = toset(keys(local.vpcs))

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_route_table[each.value].id
}

resource "aws_ec2_transit_gateway_route" "nat_route" {
  for_each = toset(keys(local.vpcs))

  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[each.value].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_route_table[each.value].id
}
