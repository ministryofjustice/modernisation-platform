output "tgw_vpc_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.live_data.id
}

output "tgw_route_table" {
  value = data.aws_ec2_transit_gateway_route_table.live_data.id
}
