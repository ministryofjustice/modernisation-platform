provider "aws" {
  alias = "core-network-services"
}

# Get AZs for account
data "aws_availability_zones" "available" {
  state = "available"
}

# Locals
locals {
  availability_zones = sort(data.aws_availability_zones.available.names)

  nacl_rules = [
    { egress : false, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 810, cidr : "10.0.0.0/8" },
    { egress : false, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 820, cidr : "172.16.0.0/12" },
    { egress : false, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 830, cidr : "192.168.0.0/16" },
    { egress : false, action : "allow", protocol : -1, from_port : 0, to_port : 0, rule_num : 910, cidr : "0.0.0.0/0" },
    { egress : true, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 810, cidr : "10.0.0.0/8" },
    { egress : true, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 820, cidr : "172.16.0.0/12" },
    { egress : true, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 830, cidr : "192.168.0.0/16" },
    { egress : true, action : "allow", protocol : -1, from_port : 0, to_port : 0, rule_num : 910, cidr : "0.0.0.0/0" }
  ]

  nacls = distinct([
    for key, subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway"
  ])


  expanded_tgw_subnets = [
    for index, cidr in cidrsubnets(var.vpc_cidr, 2, 2, 2) : {
      key  = "transit-gateway"
      cidr = cidr
      az   = local.availability_zones[index]
      type = "transit-gateway"
    }
  ]

  # Transit Gateway subnets with keys
  expanded_tgw_subnets_with_keys = {
    for subnet in local.expanded_tgw_subnets :
    "${subnet.key}-${subnet.az}" => subnet
  }

  # Worker subnets
  expanded_worker_subnets = {
    for key, subnet_set in var.subnet_sets :
    key => chunklist(cidrsubnets(subnet_set, 3, 3, 3, 4, 4, 4, 4, 4, 4), 3)
  }

  # Worker subnet associations
  expanded_worker_subnets_assocation = flatten([
    for key, subnet_set in local.expanded_worker_subnets : [
      for set_index, set in subnet_set : [
        for cidr_index, cidr in set : {
          key   = key
          cidr  = cidr
          az    = local.availability_zones[cidr_index]
          type  = set_index == 0 ? "private" : (set_index == 1 ? "public" : "data")
          group = key
        }
      ]
    ]
  ])

  # Worker subnets with keys
  expanded_worker_subnets_with_keys = {
    for subnet in local.expanded_worker_subnets_assocation :
    "${subnet.key}-${subnet.type}-${subnet.az}" => subnet
  }

  # All subnets (TGW and worker subnets)
  all_subnets_with_keys = merge(
    local.expanded_tgw_subnets_with_keys,
    local.expanded_worker_subnets_with_keys
  )

  # Distinct subnets by key type not including Transit Gateway subnets
  distinct_subnets_by_key_type = distinct([
    for subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway"
  ])

  # All distinct route tables
  all_distinct_route_tables = distinct([
    for subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
  ])

  # All distinct route table associations
  all_distinct_route_table_associations = {
    for key, subnet in local.all_subnets_with_keys :
    key => "${subnet.key}-${subnet.type}"
  }

  expanded_rules = toset(flatten([
    for key, value in toset(local.nacls) : [
      for rule_key, rule in toset(local.nacl_rules) : {
        key       = value
        egress    = rule.egress
        action    = rule.action
        protocol  = rule.protocol
        from_port = rule.from_port
        to_port   = rule.to_port
        rule_num  = rule.rule_num
        cidr      = rule.cidr
      }
    ]
  ]))
  expanded_rules_with_keys = {
    for rule in local.expanded_rules :
    "${rule.key}-${rule.cidr}-${rule.egress}-${rule.action}-${rule.protocol}-${rule.from_port}-${rule.to_port}-${rule.rule_num}" => rule
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

# VPC Flow Logs
resource "aws_cloudwatch_log_group" "default" {
  name = "${var.tags_prefix}-vpc-flow-logs"
}

resource "aws_flow_log" "cloudwatch" {
  iam_role_arn             = var.vpc_flow_log_iam_role
  log_destination          = aws_cloudwatch_log_group.default.arn
  max_aggregation_interval = "60"
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  vpc_id                   = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-vpc-flow-logs"
    }
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each = tomap(var.subnet_sets)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value
}

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

# NACLs
resource "aws_network_acl" "default" {
  for_each = toset(local.nacls)
  vpc_id   = aws_vpc.vpc.id
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.subnets["${each.key}-${az}"].id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.value}"
    },
  )
}

resource "aws_network_acl_rule" "apply_network_map_rules" {
  for_each = local.expanded_rules_with_keys

  network_acl_id = aws_network_acl.default[each.value.key].id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "allow_local_network_ingress" {
  for_each = toset(local.distinct_subnets_by_key_type)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 210
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.subnet_sets[split("-", each.value)[0]]
}

resource "aws_network_acl_rule" "allow_local_network_egress" {
  for_each = toset(local.distinct_subnets_by_key_type)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.subnet_sets[split("-", each.value)[0]]
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

resource "aws_route_table_association" "route_table_associations" {
  for_each = tomap(local.all_distinct_route_table_associations)

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.value].id
}

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

  transit_gateway_id     = var.transit_gateway_id
  route_table_id         = aws_route_table.route_tables[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}
