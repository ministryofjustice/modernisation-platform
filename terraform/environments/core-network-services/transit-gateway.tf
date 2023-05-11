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

# Associate the Inspection VPC attachments with the relevant Transit Gateway route table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_association" {
  for_each                       = local.networking
  transit_gateway_attachment_id  = module.vpc_inspection[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables[each.key].id
}

#########################
# Routes for VPC attachments
#########################
resource "aws_ec2_transit_gateway_route" "inspection_route" {
  for_each                       = local.networking
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc_inspection[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables[each.key].id
}
