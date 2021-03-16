provider "aws" {
  alias = "share-host" # Provider that holds the resource share
}

provider "aws" {
  alias = "share-tenant" # Provider that wants to be shared with
}

# Get the VPC name from the share-host
data "aws_vpc" "host" {
  provider = aws.share-host

  tags = {
    Name = var.vpc_name
  }
}

# Retag VPC in the associated principal account
resource "aws_ec2_tag" "vpc" {
  resource_id = data.aws_vpc.host.id
  key         = "Name"
  value       = var.vpc_name
}

# Get all subnet IDs in the associated principal account
data "aws_subnet_ids" "associated" {
  provider = aws.share-tenant

  vpc_id = data.aws_vpc.host.id

}

# Get corresponding subnets, including their tags, from the host account
data "aws_subnet_ids" "host" {
  provider = aws.share-host

  vpc_id = data.aws_vpc.host.id
  
  
  tags = {
    Name = "${var.vpc_name}-${var.subnet_set}*"
  }

}

# List all subnets in the host account
data "aws_subnet" "host" {
  
  provider = aws.share-host

  for_each = data.aws_subnet_ids.host.ids
  id       = each.key

   tags = {
    Name = "${var.vpc_name}-${var.subnet_set}*"
  }
}



# Retag subnets in the associated account
resource "aws_ec2_tag" "subnets" {
  
  for_each = data.aws_subnet.host

  resource_id = each.value.id
  key         = "Name"
  value       = each.value.tags.Name
}



# output "aws_subnet_host" {
  
#   #garden-production-patio
#   value = data.aws_subnet.host
# }

# output "aws_subnet_tennant" {
  
#   #garden-production-patio
#   value = data.aws_subnet_ids.associated
# }