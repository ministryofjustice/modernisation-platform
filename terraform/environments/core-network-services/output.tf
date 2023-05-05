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

output "live_data_private_route_tables" {
  value = module.vpc_hub["live_data"].private_route_tables
}

output "public_route_tables" {
  value = { for key, value in local.networking :
  key => [for az, rtb_id in module.vpc_hub[key].public_rtb_ids_and_azs : rtb_id["route_table_id"]] }
}

output "non_tgw_subnet_ids" {
  value = length(module.vpc_hub["non_live_data"].non_tgw_subnet_ids)
}

output "tgw_subnet_ids" {
  value = length(module.vpc_hub["non_live_data"].tgw_subnet_ids)
}