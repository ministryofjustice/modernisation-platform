output "live_cidr" {

    value = local.networking.live_data
}

output "nonlive-cidr" {

    value = local.networking.non_live_data
}

output "transit-gateway" {
    
    value = aws_ec2_transit_gateway.transit-gateway.id
}

output "private_route_tables" {

    value = "${module.vpc["non_live_data"].private_route_tables}"
}

output "public_igw_route" {

    value = "${module.vpc["non_live_data"].public_igw_route.destination_cidr_block}"
}

output "non_tgw_subnet_ids" {

    value = length("${module.vpc["non_live_data"].non_tgw_subnet_ids}")
}

output "tgw_subnet_ids" {

    value = length("${module.vpc["non_live_data"].tgw_subnet_ids}")
}

# output "igw_route_cidr" {
    
#     value = "${module.vpc["non_live_data"].igw_route_cidr}"
# }