resource "aws_route" "private_transit_gateway" {
  for_each = tomap(var.route_table_ids)

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

variable "transit_gateway_id" {}
variable "route_table_ids" {}
