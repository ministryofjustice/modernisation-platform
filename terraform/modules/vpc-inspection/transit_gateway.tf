resource "aws_ec2_transit_gateway_vpc_attachment" "attachments-inspection" {
  appliance_mode_support                          = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = aws_vpc.main.id
  subnet_ids                                      = [for subnet in aws_subnet.transit-gateway : subnet.id]

  tags = merge(
    var.tags_common,
    { "Name" = format("%s-attachment", var.tags_prefix),
    "inline-inspection" = "true" }
  )

  lifecycle {
    prevent_destroy = true
  }
}