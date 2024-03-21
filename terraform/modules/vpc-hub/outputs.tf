output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.default.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.default.cidr_block
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

output "non_tgw_subnet_ids_map" {
  description = "Map of subnet ids, with keys being the subnet types and values being the list of subnet ids"
  value = {
    "public"  = [for subnet in aws_subnet.public : subnet.id]
    "private" = [for subnet in aws_subnet.private : subnet.id]
    "data"    = [for subnet in aws_subnet.data : subnet.id]
  }
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

output "private_route_tables_map" {
  description = "Private route table keys and IDs, as a map organised by type"
  value = {
    "private" = {
      for key, route_table in aws_route_table.private : "${var.tags_prefix}-${key}" => route_table.id
    },
    "data" = {
      for key, route_table in aws_route_table.data : "${var.tags_prefix}-${key}" => route_table.id
    },
    "transit_gateway" = {
      for key, route_table in aws_route_table.transit-gateway : "${var.tags_prefix}-${key}" => route_table.id
    }
  }
}

output "public_route_tables" {
  description = "Public route tables"
  value       = aws_route_table.public
}

output "public_igw_route" {
  description = "Public Internet Gateway route"
  value       = aws_route.public-internet-gateway
}
output "vpc_cloudwatch_name" {
  value = aws_cloudwatch_log_group.default.name
}