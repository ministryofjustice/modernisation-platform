#########################
# Create Transit Gateway
#########################
resource "aws_ec2_transit_gateway" "transit-gateway" {
  #checkov:skip=CKV_AWS_331
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

######################################
# Centralised endpoints VPC attachment
######################################
# TGW attachment for the centralised endpoint hub VPC.
# Disables default route table association/propagation — managed explicitly below
# and in transit_gateway_connections.tf.
resource "aws_ec2_transit_gateway_vpc_attachment" "centralised_endpoints" {
  transit_gateway_id                              = aws_ec2_transit_gateway.transit-gateway.id
  vpc_id                                          = module.vpc_centralised_endpoints.vpc_id
  subnet_ids                                      = module.vpc_centralised_endpoints.tgw_subnet_ids
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    local.tags,
    { Name = "centralised-endpoints-attachment" }
  )
}

# Dedicated TGW route table for the hub attachment.
resource "aws_ec2_transit_gateway_route_table" "centralised_endpoints" {
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  tags = merge(local.tags, { Name = "centralised_endpoints" })
}

# Associate the hub attachment with its dedicated TGW route table.
resource "aws_ec2_transit_gateway_route_table_association" "centralised_endpoints" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.centralised_endpoints.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.centralised_endpoints.id
}
