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

output "inspection_igw_id" {
  value = {
    for vpc_key, vpc_value in local.networking : vpc_key => module.vpc_inspection[vpc_key].internet_gateway.id
  }
}

output "inspection_natgw_ids" {
  value = {
    for vpc_key, vpc_value in local.networking : vpc_key => length([
    for key in module.vpc_inspection[vpc_key].nat_gateway : key.id])
  }
}

output "inspection_default_routes" {
  value = {
    live_data     = { for key, value in data.aws_route.live_data : key => value.destination_cidr_block }
    non_live_data = { for key, value in data.aws_route.non_live_data : key => value.destination_cidr_block }
  }
}

output "centralised_endpoint_vpc_id" {
  value = module.vpc_centralised_endpoints.vpc_id
}

output "centralised_interface_endpoint_arns" {
  value = {
    for name, endpoint in aws_vpc_endpoint.centralised_interface_endpoints :
    name => endpoint.arn
  }
}


output "centralised_endpoint_route53_profile_id" {
  value = aws_route53profiles_profile.centralised_endpoint_dns_profile.id
}

output "centralised_endpoint_route53_profile_arn" {
  value = aws_route53profiles_profile.centralised_endpoint_dns_profile.arn
}

output "centralised_vpc_endpoint_ram_share_arn" {
  value = aws_ram_resource_share.centralised_vpc_endpoints.arn
}

output "centralised_route53_profile_ram_share_arn" {
  value = aws_ram_resource_share.centralised_endpoint_dns_profile.arn
}
