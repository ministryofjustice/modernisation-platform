resource "aws_ec2_transit_gateway_route" "example" {
  for_each = tomap(var.subnet_sets)

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = var.tgw_vpc_attachment
  transit_gateway_route_table_id = var.tgw_route_table
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.type]
  }
}

data "aws_route_table" "main-public" {
  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = ["${var.type}-public"]
  }
}

resource "aws_route" "main" {
  for_each = tomap(var.subnet_sets)

  route_table_id         = data.aws_route_table.main-public.id
  destination_cidr_block = each.value
  transit_gateway_id     = var.tgw_id
}
