output "live_cidr" {

    value = local.networking.live_data
}

output "nonlive-cidr" {

    value = local.networking.non_live_data
}

output "transit-gateway" {
    
    value = data.aws_ec2_transit_gateway.transit-gateway.id
}

