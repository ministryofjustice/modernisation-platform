provider "aws" {
  alias = "core-network-services"
}

# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}

# locals {
#   availability_zones = sort(data.aws_availability_zones.available.names)
#   # subnets_map outputs the following:
#   # [
#   #   {
#   #     az   = "eu-west-2a"
#   #     cidr = "10.230.8.0/23"
#   #     type = "private"
#   #   },
#   #   {
#   #     az   = "eu-west-2b"
#   #     cidr = "10.230.10.0/23"
#   #     type = "private"
#   #   }...
#   # ]
#   subnets_map = flatten([
#     for k, v in var.subnet_cidrs_by_type : [
#       for index, cidr in v : {
#         type = k
#         cidr = cidr
#         az   = local.availability_zones[index]
#       }
#     ]
#   ])
#   # subnets_map_assocations outputs the following:
#   # {
#   #   private-eu-west-2a = {
#   #     az   = "eu-west-2a"
#   #     cidr = "10.230.8.0/23"
#   #     type = "private"
#   #   }
#   #   private-eu-west-2b = {
#   #     az   = "eu-west-2b"
#   #     cidr = "10.230.10.0/23"
#   #     type = "private"
#   #   }
#   # }...
#   subnets_map_associations = {
#     for subnet in local.subnets_map :
#     "${subnet.type}-${subnet.az}" => {
#       cidr = subnet.cidr
#       az   = subnet.az
#       type = subnet.type
#     }
#   }
# }

# Locals
locals {
  availability_zones = sort(data.aws_availability_zones.available.names)

  expanded_tgw_subnets = [
    for index, cidr in cidrsubnets(var.vpc_cidr, 2, 2, 2) : {
      key  = "transit-gateway"
      cidr = cidr
      az   = local.availability_zones[index]
      type = "transit-gateway"
    }
  ]

  expanded_tgw_subnets_with_keys = {
    for subnet in local.expanded_tgw_subnets :
    "${subnet.key}-${subnet.az}" => subnet
  }

  expanded_worker_subnets = {
    for key, subnet_set in var.subnet_sets :
    key => chunklist(cidrsubnets(subnet_set, 3, 3, 3, 4, 4, 4, 4, 4, 4), 3)
  }
  expanded_worker_subnets_assocation = flatten([
    for key, subnet_set in local.expanded_worker_subnets : [
      for set_index, set in subnet_set : [
        for cidr_index, cidr in set : {
          key  = key
          cidr = cidr
          type = set_index == 0 ? "private" : (set_index == 1 ? "public" : "data")
          az   = local.availability_zones[cidr_index]
        }
      ]
    ]
  ])
  expanded_worker_subnets_with_keys = {
    for subnet in local.expanded_worker_subnets_assocation :
    "${subnet.key}-${subnet.type}-${subnet.az}" => subnet
  }

  all_subnets_with_keys = merge(
    local.expanded_tgw_subnets_with_keys,
    local.expanded_worker_subnets_with_keys
  )

  all_distinct_route_tables = distinct([
    for key, subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
  ])

  all_route_table_associations = {
    for key, subnet in local.all_subnets_with_keys :
    key => "${subnet.key}-${subnet.type}"
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

resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each = tomap(var.subnet_sets)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value
}

# # NACLs
# resource "aws_network_acl" "default" {
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_network_acl_rule" "ingress" {
#   for_each = (var.nacl_ingress != null) ? tomap(var.nacl_ingress) : {}

#   network_acl_id = aws_network_acl.default.id
#   egress         = false

#   # Source/destination
#   cidr_block     = each.value.cidr_block

#   # Protocol
#   protocol = each.value.protocol

#   # Rules
#   rule_action = each.value.rule_action
#   rule_number = each.value.rule_number

#   # Ports
#   # from_port = each.value.from_port ? each.value.from_port : null
#   # to_port   = each.value.to_port ? each.value.to_port : null
# }

# # resource "aws_network_acl_rule" "egress" {
# #   for_each = var.nacl_egress

# #   network_acl_id = aws_network_acl.default.id
# #   cidr_block     = aws_vpc.vpc.cidr_block
# #   egress         = true

# #   # Source/destination
# #   cidr_block     = each.value.cidr_block

# #   # Protocol
# #   protocol = each.value.protocol

# #   # Rules
# #   rule_action = each.value.rule_action
# #   rule_number = each.value.rule_number

# #   # Ports
# #   from_port = each.value.from_port
# #   to_port   = each.value.to_port
# # }

# VPC: Subnet per type, per availability zone
resource "aws_subnet" "subnets" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.default]

  for_each = tomap(local.all_subnets_with_keys)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = each.key
    }
  )
}

# resource "aws_subnet" "tgw" {
#   for_each = tomap(local.expanded_tgw_subnets_with_keys)

#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = each.value.cidr
#   availability_zone = each.value.az

#   tags = merge(
#     var.tags_common,
#     {
#       Name = each.key
#     }
#   )
# }

# resource "aws_subnet" "sets" {
#   depends_on = [aws_vpc_ipv4_cidr_block_association.default]

#   for_each = tomap(local.expanded_worker_subnets_with_keys)

#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = each.value.cidr
#   availability_zone = each.value.az

#   tags = merge(
#     var.tags_common,
#     {
#       Name = each.key
#     }
#   )
# }

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

resource "aws_route_table" "route_tables" {
  for_each = toset(local.all_distinct_route_tables)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.value}"
    }
  )
}

# Route table per type, per AZ (apart from public, which is separate)
# resource "aws_route_table" "tgw" {

#   vpc_id = aws_vpc.vpc.id

#   tags = merge(
#     var.tags_common,
#     {
#       Name = "${var.tags_prefix}-tgw"
#     },
#   )
# }

# Route table per type, per AZ (apart from public, which is separate)
# resource "aws_route_table" "public" {
#   for_each = var.subnet_sets

#   vpc_id = aws_vpc.vpc.id

#   tags = merge(
#     var.tags_common,
#     {
#       Name = "${var.tags_prefix}-${each.key}-public"
#     },
#   )
# }

# Public Internet Gateway route
# resource "aws_route" "public_ig" {
#   for_each = aws_route_table.public

#   route_table_id         = aws_route_table.public[each.key].id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.ig.id
# }
resource "aws_route" "public_ig" {
  for_each = {
    for key, route_table in aws_route_table.route_tables :
    key => route_table
    if substr(key, length(key) - 6, length(key)) == "public"
  }

  route_table_id         = aws_route_table.route_tables[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "tgw" {
  for_each = {
    for key, route_table in aws_route_table.route_tables :
    key => route_table
    if substr(key, length(key) - 6, length(key)) != "public"

  }

  transit_gateway_id = var.transit_gateway_id
  route_table_id = aws_route_table.route_tables[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}

# # Route table per type, per AZ
# resource "aws_route_table" "private" {
#   for_each = var.subnet_sets

#   vpc_id = aws_vpc.vpc.id

#   tags = merge(
#     var.tags_common,
#     {
#       Name = "${var.tags_prefix}-${each.key}-private"
#     },
#   )
# }

# # Route table per type, per AZ
# resource "aws_route_table" "data" {
#   for_each = var.subnet_sets

#   vpc_id = aws_vpc.vpc.id

#   tags = merge(
#     var.tags_common,
#     {
#       Name = "${var.tags_prefix}-${each.key}-data"
#     },
#   )
# }


# # Private NAT routes
# resource "aws_route" "default_nat" {
#   for_each = {
#     for key in keys(local.subnets_map_associations) :
#     key => local.subnets_map_associations[key]
#     if substr(key, 0, 6) != "public" && (var.enable_nat_gateway == true)
#   }

#   route_table_id         = aws_route_table.default[each.key].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.default["public-${substr(each.key, length(each.key) - 10, length(each.key))}"].id
# }

# resource "aws_route" "shared_tgw" {

#   route_table_id         = aws_route_table.tgw.id
#   destination_cidr_block = "0.0.0.0/0"
#   # transit_gateway_id     = var.transit_gateway_id
# }

resource "aws_route_table_association" "route_table_associations" {
  for_each = tomap(local.all_route_table_associations)

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.value].id
}

# # # Route table associations
# resource "aws_route_table_association" "sets" {
#   for_each = local.expanded_worker_subnets_with_keys

#   subnet_id      = aws_subnet.sets["${each.value.key}-${each.value.type}-${each.value.az}"].id
#   route_table_id = (each.value.type == "public") ? aws_route_table.public[each.value.key].id : (each.value.type == "data") ? aws_route_table.data[each.value.key].id : aws_route_table.private[each.value.key].id
# }

# resource "aws_route_table_association" "tgw" {
#   for_each = local.expanded_tgw_subnets_with_keys

#   subnet_id      = aws_subnet.tgw["${each.value.key}-${each.value.az}"].id
#   route_table_id = aws_route_table.tgw.id
# }

# Get route table
# data "aws_ec2_transit_gateway_route_table" "example" {
#   provider = aws.core-network-services

#   filter {
#     name   = "tag:Name"
#     values = ["live"]
#   }
# }

# resource "aws_ec2_transit_gateway_route_table" "default" {
#   provider = aws.core-network-services
#   transit_gateway_id = var.transit_gateway_id

#   tags = {}
# }

# resource "aws_ec2_transit_gateway_route" "default" {
#   provider = aws.core-network-services

#   destination_cidr_block         = "0.0.0.0/0"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.example.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.example.association_default_route_table_id
# }
