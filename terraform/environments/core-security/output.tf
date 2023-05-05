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

output "live_data_private_route_tables" {

  value = module.vpc["live_data"].private_route_tables
}

output "public_route_tables" {
  value = { for key, value in local.networking :
  key => [for az, rtb_id in module.vpc[key].public_rtb_ids_and_azs : rtb_id["route_table_id"]] }
}

output "non_tgw_subnet_ids" {

  value = length(module.vpc["non_live_data"].non_tgw_subnet_ids)
}

output "tgw_subnet_ids" {

  value = length(module.vpc["non_live_data"].tgw_subnet_ids)
}