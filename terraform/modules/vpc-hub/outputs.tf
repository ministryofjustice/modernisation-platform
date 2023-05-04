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

output "tgw_rtb_ids_and_azs" {
  description = "Supplies a map of transit gateway route table ids and associated availability zones"
  value = {
    for subnet_key, subnet_value in aws_subnet.transit-gateway :
    "${var.tags_prefix}-${subnet_key}" => {
      route_table_id    = aws_route_table.transit-gateway[subnet_key].id
      availability_zone = subnet_value.availability_zone
    }
  }
}

output "public_rtb_ids_and_azs" {
  description = "Supplies a map of public-inspection route table ids and associated availability zones. "
  value = var.inline_inspection == true ? {
    for subnet_key, subnet_value in aws_subnet.public :
    "${var.tags_prefix}-${subnet_key}" => {
      route_table_id    = aws_route_table.public-inspection[subnet_key].id
      availability_zone = subnet_value.availability_zone
    }
  } : {}
}

output "inspection_rtb_ids_and_azs" {
  description = "Supplies a map of inspection route table ids and associated availability zones. "
  value = var.inline_inspection == true ? {
    for subnet_key, subnet_value in aws_subnet.inspection :
    "${var.tags_prefix}-${subnet_key}" => {
      route_table_id    = aws_route_table.inspection[subnet_key].id
      availability_zone = subnet_value.availability_zone
    }
  } : {}
}

output "nat_gateways" {
  value = (var.gateway == "nat") ? {
    for name, gateway in aws_nat_gateway.public : substr(name, 7, -1) => {
      "availability_zone" = substr(name, 7, -1)
      "gateway_id"        = gateway.id
    }
  } : {}
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
    ], [
    for subnet in aws_subnet.inspection :
    subnet.id
  ])
}

output "non_tgw_subnet_ids_map" {
  description = "Map of subnet ids, with keys being the subnet types and values being the list of subnet ids"
  value = {
    "public"     = [for subnet in aws_subnet.public : subnet.id]
    "private"    = [for subnet in aws_subnet.private : subnet.id]
    "data"       = [for subnet in aws_subnet.data : subnet.id]
    "inspection" = var.inline_inspection ? [for subnet in aws_subnet.inspection : subnet.id] : []
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
  value = merge({
    for key, route_table in aws_route_table.public :
    "${var.tags_prefix}-${key}" => route_table.id
    }, {
    for key, route_table in aws_route_table.public-inspection :
    "${var.tags_prefix}-${key}" => route_table.id
  })
}

output "public_igw_route" {
  description = "Public Internet Gateway route"
  value = merge({
    for key, route in aws_route.public-internet-gateway :
    "${var.tags_prefix}-${key}" => route
    }, {
    for key, route in aws_route.public-internet-gateway-inspection :
    "${var.tags_prefix}-${key}" => route
  })
}