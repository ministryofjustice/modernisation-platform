output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, value in local.expanded_subnets_with_keys :
    aws_subnet.subnets[key].id
    if value.type == "tgw"
  ]
}

output "non_tgw_subnet_ids" {
  description = "Transit Gateway subnet IDs"
  value = [
    for key, value in local.expanded_subnets_with_keys :
    aws_subnet.subnets[key].id
    if value.type != "tgw"
  ]
}
