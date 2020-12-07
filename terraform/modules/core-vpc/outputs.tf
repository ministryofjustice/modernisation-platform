output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.vpc.id
}

output "tgw_subnet_ids" {
  description = "id of Transit Gateway subnets"
  value = [
    for key, subnet in aws_subnet.default :
    subnet.id
    if substr(key, 0, 3) == "tgw"
  ]
}
