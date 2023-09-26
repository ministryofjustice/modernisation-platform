output "live_cidr" {

  value = local.networking.live_data
}

output "nonlive-cidr" {

  value = local.networking.non_live_data
}

output "transit-gateway" {

  value = data.aws_ec2_transit_gateway.transit-gateway.id
}

#TESTING VARIABLES ---------------

output "vpc_cidrs" {
  value = {
    for key, value in local.networking :
    key => value
  }
}

output "non_live_data_private_route_tables" {

  value = module.vpc["non_live_data"].private_route_tables
}

output "public_route_tables" {
  value = {
    for key, value in local.networking :
    key => module.vpc[key].public_route_tables.tags["Name"]
  }
}

output "live_data_private_route_tables" {

  value = module.vpc["live_data"].private_route_tables
}

output "public_igw_route" {
  value = {
    for key, value in local.networking :
    key => module.vpc[key].public_igw_route.destination_cidr_block
  }
}

output "non_tgw_subnet_ids" {

  value = length(module.vpc["non_live_data"].non_tgw_subnet_ids)
}

output "tgw_subnet_ids" {

  value = length(module.vpc["non_live_data"].tgw_subnet_ids)
}

output "image_builder_security_group_id" {
  value = { for k, v in aws_security_group.image_builder_security_group : k => v.id }
}

output "non_live_private_subnet_ids" {
  value = module.vpc["non_live_data"].non_tgw_subnet_ids_map["private"]
}
