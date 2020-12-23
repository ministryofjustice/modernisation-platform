# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = sort(data.aws_availability_zones.available.names)
  # subnets_map outputs the following:
  # [
  #   {
  #     az   = "eu-west-2a"
  #     cidr = "10.230.8.0/23"
  #     type = "private"
  #   },
  #   {
  #     az   = "eu-west-2b"
  #     cidr = "10.230.10.0/23"
  #     type = "private"
  #   }...
  # ]
  subnets_map = flatten([
    for k, v in var.subnet_cidrs_by_type : [
      for index, cidr in v : {
        type = k
        cidr = cidr
        az   = local.availability_zones[index]
      }
    ]
  ])
  # subnets_map_assocations outputs the following:
  # {
  #   private-eu-west-2a = {
  #     az   = "eu-west-2a"
  #     cidr = "10.230.8.0/23"
  #     type = "private"
  #   }
  #   private-eu-west-2b = {
  #     az   = "eu-west-2b"
  #     cidr = "10.230.10.0/23"
  #     type = "private"
  #   }
  # }...
  subnets_map_associations = {
    for subnet in local.subnets_map :
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

# NACLs
resource "aws_network_acl" "default" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_network_acl_rule" "ingress" {
  for_each = (var.nacl_ingress != null) ? tomap(var.nacl_ingress) : {}

  network_acl_id = aws_network_acl.default.id
  egress         = false

  # Source/destination
  cidr_block = each.value.cidr_block

  # Protocol
  protocol = each.value.protocol

  # Rules
  rule_action = each.value.rule_action
  rule_number = each.value.rule_number

  # Ports
  # from_port = each.value.from_port ? each.value.from_port : null
  # to_port   = each.value.to_port ? each.value.to_port : null
}

# resource "aws_network_acl_rule" "egress" {
#   for_each = var.nacl_egress

#   network_acl_id = aws_network_acl.default.id
#   cidr_block     = aws_vpc.vpc.cidr_block
#   egress         = true

#   # Source/destination
#   cidr_block     = each.value.cidr_block

#   # Protocol
#   protocol = each.value.protocol

#   # Rules
#   rule_action = each.value.rule_action
#   rule_number = each.value.rule_number

#   # Ports
#   from_port = each.value.from_port
#   to_port   = each.value.to_port
# }

# VPC: Subnet per type, per availability zone
resource "aws_subnet" "default" {
  for_each = local.subnets_map_associations

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
    for key in keys(local.subnets_map_associations) :
    key => local.subnets_map_associations[key]
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
    for key in keys(local.subnets_map_associations) :
    key => local.subnets_map_associations[key]
    if substr(key, 0, 6) != "public" && (var.enable_nat_gateway == true)
  }

  route_table_id         = aws_route_table.default[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default["public-${substr(each.key, length(each.key) - 10, length(each.key))}"].id
}

resource "aws_route" "shared_tgw" {
  for_each = {
    for key in keys(local.subnets_map_associations) :
    key => local.subnets_map_associations[key]
    if substr(key, 0, 6) != "public" && (var.shared_resource == true)
  }

  route_table_id         = aws_route_table.default[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

# Elastic IPs for NAT Gateway
resource "aws_eip" "default" {
  for_each = {
    for key in keys(local.subnets_map_associations) :
    key => local.subnets_map_associations[key]
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
    for key in keys(local.subnets_map_associations) :
    key => local.subnets_map_associations[key]
    if substr(key, 0, 6) == "public" && (var.enable_nat_gateway == true)
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
  for_each = local.subnets_map_associations

  subnet_id      = aws_subnet.default[each.key].id
  route_table_id = substr(each.key, 0, 6) == "public" ? aws_route_table.public.id : aws_route_table.default[each.key].id
}
