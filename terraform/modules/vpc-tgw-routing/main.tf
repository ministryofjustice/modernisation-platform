resource "aws_ec2_transit_gateway_route" "example" {
  for_each = tomap(var.subnet_sets)

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = var.tgw_vpc_attachment
  transit_gateway_route_table_id = var.tgw_route_table
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["live_data"]
  }
}

data "aws_route_table" "live_data-public" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = ["live_data-public"]
  }
}

resource "aws_route" "test" {
  for_each = tomap(var.subnet_sets)

  route_table_id         = data.aws_route_table.live_data-public.id
  destination_cidr_block = each.value
  transit_gateway_id     = var.tgw_id
}
