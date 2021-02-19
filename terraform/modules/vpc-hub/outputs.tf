output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.default.id
}

output "tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value       = [for subnet in aws_subnet.transit-gateway : subnet.id]
}

output "non_tgw_subnet_ids" {
  description = "Non-Transit Gateway subnet IDs (public, private, data)"
  value = concat([
    for subnet in aws_subnet.public :
    subnet.id
    ], [
    for subnet in aws_subnet.private :
    subnet.id
    ], [
    for subnet in aws_subnet.data :
    subnet.id
  ])
}

output "private_route_tables" {
  description = "Private route table keys and IDs"
  value = merge({
    for key, route_table in aws_route_table.private :
    "${var.tags_prefix}-${key}" => route_table.id
    }, {
    for key, route_table in aws_route_table.data :
    "${var.tags_prefix}-${key}" => route_table.id
    }, {
    for key, route_table in aws_route_table.transit-gateway :
    "${var.tags_prefix}-${key}" => route_table.id
  })
}

output "public_route_tables" {
  description = "Public route tables"
  value = aws_route_table.public
}

output "public_igw_route" {
  description = "Public Internet Gateway route"
  value = aws_route.public-internet-gateway
}

