output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, subnet in aws_subnet.subnets :
    subnet.id
    if substr(key, 0, 15) == "transit-gateway"
  ]
}

output "non_tgw_subnet_arns" {
  description = "Non-Transit Gateway and Protected subnet ARNs"
  value = [
    for key, subnet in aws_subnet.subnets :
    subnet.arn

    if substr(key, 0, 15) != "transit-gateway"
  ]
}

output "non_tgw_subnet_arns_by_set" {
  value = {
    for set, cidr in var.subnet_sets :
    set => {
      for key, subnet in local.expanded_worker_subnets_assocation :
      "${key}-${cidr}" => aws_subnet.subnets[key].arn
      if substr(key, 0, length(set)) == set
    }
  }
}

output "non_tgw_subnet_arns_by_subnetset" {
  value = {
    for set, cidr in var.subnet_sets : set =>
    {
      for key, subnet in local.expanded_worker_subnets_assocation :
      "${key}-${cidr}" => aws_subnet.subnets["${subnet.key}-${subnet.type}-${subnet.az}"].arn
      if substr(subnet.key, 0, length(set)) == set

    }
  }
}


locals {
  network_acl_refs = { for value in aws_network_acl.default :

    value.tags.Name =>
    {
      arn  = value.arn
      id   = value.id
      name = value.tags.Name
    }
  }

  data_network_acl_for_endpoints = flatten([
    for value in aws_network_acl.default : [
      for cidr_index, cidr in aws_vpc_endpoint.ssm_s3.cidr_blocks : {
        id         = value.id
        name       = value.tags.Name
        cidr       = cidr
        cidr_index = cidr_index
      }
      if substr(value.tags.Name, -4, -1) == "data"
    ]
  ])
}

output "nacl_refs" {
  value = local.network_acl_refs
}

output "data_network_acl_for_endpoints" {
  value = local.data_network_acl_for_endpoints
}

output "expanded_worker_subnets_assocation" {
  value = local.expanded_worker_subnets_assocation
}
output "expanded_worker_subnets_with_keys" {
  value = local.expanded_worker_subnets_with_keys
}

# output "test" {
#   value = local.subnet_sets_with_index
# }
