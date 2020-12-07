# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = sort(data.aws_availability_zones.available.names)
  test = flatten([
    for k, v in var.subnet_cidrs_by_type : [
      for index, cidr in v : {
        type = k
        cidr = cidr
        az   = local.availability_zones[index]
      }
    ]
  ])
  another_test = {
    for subnet in local.test :
    "${subnet.type}-${subnet.az}" => {
      cidr = subnet.cidr
      az   = subnet.az
      type = subnet.type
    }
  }
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags_common,
    {
      Name = var.tags_prefix
    },
  )
}

# VPC: Subnet per type, per availability zone
resource "aws_subnet" "default" {
  for_each = local.another_test

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.value.type}-${each.value.az}"
    }
  )
}

# VPC: Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-IG"
    },
  )
}

# Route table per type, per AZ (apart from public, which is separate)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-public"
    },
  )
}

# Public Internet Gateway route
resource "aws_route" "public_ig" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Non-public route tables
resource "aws_route_table" "default" {
  for_each = {
    for key in keys(local.another_test) :
    key => local.another_test[key]
    if substr(key, 0, 6) != "public"
  }
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Private NAT routes
resource "aws_route" "default_nat" {
  for_each = {
    for key in keys(local.another_test) :
    key => local.another_test[key]
    if substr(key, 0, 6) != "public"
  }

  route_table_id         = aws_route_table.default[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default["public-${substr(each.key, length(each.key) - 10, length(each.key))}"].id
}

# Elastic IPs for NAT Gateway
resource "aws_eip" "default" {
  for_each = {
    for key in keys(local.another_test) :
    key => local.another_test[key]
    if substr(key, 0, 6) == "public"
  }

  vpc = true

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-nat-eip-${each.key}"
    },
  )
}

# Public NAT Gateway
resource "aws_nat_gateway" "default" {
  for_each = {
    for key in keys(local.another_test) :
    key => local.another_test[key]
    if substr(key, 0, 6) == "public"
  }

  allocation_id = aws_eip.default[each.key].id
  subnet_id     = aws_subnet.default[each.key].id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-nat-gateway-${each.key}"
    }
  )
}

# Route table associations
resource "aws_route_table_association" "default" {
  for_each = local.another_test

  subnet_id      = aws_subnet.default[each.key].id
  route_table_id = substr(each.key, 0, 6) == "public" ? aws_route_table.public.id : aws_route_table.default[each.key].id
}
