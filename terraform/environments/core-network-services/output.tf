output "live_cidr" {
  value = local.networking.live_data
}

output "nonlive-cidr" {
  value = local.networking.non_live_data
}

#TESTING VARIABLES ---------------

output "vpc_cidrs" {
  value = {
    for key, value in local.networking :
    key => value
  }
}

output "transit_gateway" {
  value = aws_ec2_transit_gateway.transit-gateway.amazon_side_asn
}

output "transit_gateway_ram_share" {
  value = aws_ram_resource_share.transit-gateway.name
}

output "non_live_data_private_route_tables" {
  value = module.vpc_hub["non_live_data"].private_route_tables
}

output "public_route_tables" {
  value = {
    for key, value in local.networking :
    key => module.vpc_hub[key].public_route_tables.tags["Name"]
  }
}

output "live_data_private_route_tables" {
  value = module.vpc_hub["live_data"].private_route_tables
}

output "public_igw_route" {
  value = {
    for key, value in local.networking :
    key => module.vpc_hub[key].public_igw_route.destination_cidr_block
  }
}

output "non_tgw_subnet_ids" {
  value = length(module.vpc_hub["non_live_data"].non_tgw_subnet_ids)
}

output "tgw_subnet_ids" {
  value = length(module.vpc_hub["non_live_data"].tgw_subnet_ids)
}

###

output "inspection_tgw_subnets" {
  value = {
    for vpc_key, vpc_value in local.networking : vpc_key => length([
      for subnet_key, subnet_value in module.vpc_inspection[vpc_key].subnet_attributes.transit_gateway : subnet_value[0].id
    ])
  }
}

output "inspection_inspection_subnets" {
  value = {
    for vpc_key, vpc_value in local.networking : vpc_key => length([
      for subnet_key, subnet_value in module.vpc_inspection[vpc_key].subnet_attributes.inspection : subnet_value[0].id
    ])
  }
}

output "inspection_public_subnets" {
  value = {
    for vpc_key, vpc_value in local.networking : vpc_key => length([
      for subnet_key, subnet_value in module.vpc_inspection[vpc_key].subnet_attributes.public : subnet_value[0].id
    ])
  }
}

output "firewall_arn" {
  value = {
    for vpc_key, vpc_value in local.networking : vpc_key => module.vpc_inspection[vpc_key].firewall.arn
  }
}

output "inspection_vpc_ids" {
  value = {
    for vpc_key, vpc_value in local.networking : vpc_key => module.vpc_inspection[vpc_key].vpc_id
  }
}