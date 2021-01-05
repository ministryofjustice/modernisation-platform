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

output "debug" {
  value = local.expanded_rules_with_keys
}
output "expanded_worker_subnets_assocation" {
  value = local.expanded_worker_subnets_assocation
}
output "expanded_worker_subnets_with_keys" {
  value = local.expanded_worker_subnets_with_keys
}
