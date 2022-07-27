resource "aws_route" "main" {
  for_each = tomap(var.subnet_sets)

  route_table_id         = var.route_table.id
  destination_cidr_block = each.value
  transit_gateway_id     = var.tgw_id
}
