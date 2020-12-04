output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.vpc.id
}

output "private_tgw_subnet_ids" {
  description = "id of Transit Gateway subnets"
  value       = aws_subnet.private_tgw.*.id
}
