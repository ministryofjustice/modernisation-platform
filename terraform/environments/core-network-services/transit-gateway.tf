#########################
# Create TGW
#########################
resource "aws_ec2_transit_gateway" "TGW" {
  description                     = "ModernisationPlatform Transit Gateway"
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = var.enable_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.enable_default_route_table_propagation ? "enable" : "disable"
  auto_accept_shared_attachments  = var.enable_auto_accept_shared_attachments ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
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
  for_each           = toset(var.env_vpcs)
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
resource "aws_ec2_transit_gateway_vpc_attachment" "attachments" {
  for_each                                        = toset(var.env_vpcs)
  transit_gateway_id                              = aws_ec2_transit_gateway.TGW.id
  vpc_id                                          = each.value == "live" ? module.live_vpc.vpc_id : module.non_live_vpc.vpc_id
  subnet_ids                                      = each.value == "live" ? module.live_vpc.private_tgw_subnet_ids : module.non_live_vpc.private_tgw_subnet_ids
  transit_gateway_default_route_table_association = false
  dns_support                                     = "enable"
  ipv6_support                                    = "disable"
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
  count                          = length(var.env_vpcs)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[var.env_vpcs[count.index]].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_route_table[var.env_vpcs[count.index]].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagation" {
  count                          = length(var.env_vpcs)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachments[var.env_vpcs[count.index]].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_route_table[var.env_vpcs[count.index]].id
}
