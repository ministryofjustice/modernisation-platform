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

# output "tgw_subnet_ids" {
#   description = "Transit Gateway subnet IDs"
#   value = [
#     for key, subnet in aws_subnet.default :
#     subnet.id
#     if substr(key, 0, 3) == "tgw"
#   ]
# }

# output "non_tgw_subnet_ids" {
#   description = "Non-Transit Gateway subnet IDs"
#   value = [
#     for key, subnet in aws_subnet.default :
#     subnet.arn
#     if substr(key, 0, 3) != "tgw"
#   ]
# }

locals {
  network_acl_refs = { for value in aws_network_acl.default :

    value.tags.Name =>
    {
      arn  = value.arn
      id   = value.id
      name = value.tags.Name
    }
  }
}

output "nacl_refs" {
  value = local.network_acl_refs
}

output "expanded_worker_subnets_assocation" {
  value = local.expanded_worker_subnets_assocation
}
output "expanded_worker_subnets_with_keys" {
  value = local.expanded_worker_subnets_with_keys
}
