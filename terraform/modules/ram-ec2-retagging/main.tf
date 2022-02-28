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

data "aws_subnets" "associated" {
  provider = aws.share-host
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.host.id]
  }
  tags = {
    Name = "${var.vpc_name}-${var.subnet_set}*"
  }
}

# List all subnets in the host account
data "aws_subnet" "host" {

  provider = aws.share-host

  for_each = toset(data.aws_subnets.associated.ids)
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