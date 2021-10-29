resource "aws_route" "main" {
  route_table_id         = data.aws_route_table.main-public.id
  destination_cidr_block = var.vpc_cidr_range
  transit_gateway_id     = var.tgw_id
}

resource "aws_ec2_transit_gateway_route" "return_traffic" {
  destination_cidr_block         = var.vpc_cidr_range
  transit_gateway_attachment_id  = var.tgw_vpc_attachment
  transit_gateway_route_table_id = var.tgw_route_table
}
