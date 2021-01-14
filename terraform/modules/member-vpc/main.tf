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

  protected_subnet_nacl_indexes = [310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330]

  # Network AccessControlList rules (NACL's)
  nacl_rules = [
    { egress : false, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 810, cidr : "10.0.0.0/8" },
    { egress : false, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 820, cidr : "172.16.0.0/12" },
    { egress : false, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 830, cidr : "192.168.0.0/16" },
    { egress : true, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 810, cidr : "10.0.0.0/8" },
    { egress : true, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 820, cidr : "172.16.0.0/12" },
    { egress : true, action : "deny", protocol : -1, from_port : 0, to_port : 0, rule_num : 830, cidr : "192.168.0.0/16" }
  ]
  nacls = distinct([
    for key, subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway"
  ])


  # Transit Gateway subnets
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


  # Protected subnets
  expanded_protected_subnets = [
    for index, cidr in cidrsubnets(var.protected, 2, 2, 2) : {
      key  = "protected"
      cidr = cidr
      az   = local.availability_zones[index]
      type = "protected"
    }
  ]
  expanded_protected_subnets_with_keys = {
    for subnet in local.expanded_protected_subnets :
    "${subnet.key}-${subnet.az}" => subnet
  }


  # Worker subnets
  expanded_worker_subnets = {
    for key, subnet_set in var.subnet_sets :
    key => chunklist(cidrsubnets(subnet_set, 3, 3, 3, 4, 4, 4, 4, 4, 4), 3)
  }
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
  expanded_worker_subnets_with_keys = {
    for subnet in local.expanded_worker_subnets_assocation :
    "${subnet.key}-${subnet.type}-${subnet.az}" => subnet
  }

  # All subnets (TGW and worker subnets)
  all_subnets_with_keys = merge(
    local.expanded_tgw_subnets_with_keys,
    local.expanded_worker_subnets_with_keys,
    # local.expanded_protected_subnets_with_keys
  )

  # Distinct subnets by key type not including Transit Gateway subnets
  distinct_subnets_by_key_type = distinct([
    for subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway"
  ])

  # Distinct subnets by key type not including Transit Gateway or data subnets
  distinct_subnets_by_key_type_excluding_data = distinct([
    for subnet in local.all_subnets_with_keys :
    "${subnet.key}-${subnet.type}"
    if subnet.key != "transit-gateway" && subnet.type != "data"
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

  protected_nacl_rules = toset(flatten([
    for rule_key, rule in toset(local.nacl_rules) : {
      key       = rule_key
      egress    = rule.egress
      action    = rule.action
      protocol  = rule.protocol
      from_port = rule.from_port
      to_port   = rule.to_port
      rule_num  = rule.rule_num
      cidr      = rule.cidr
    }
  ]))
  protected_nacl_rules_with_keys = {
    for rule in local.protected_nacl_rules :
    "${rule.cidr}-${rule.egress}-${rule.action}-${rule.protocol}-${rule.from_port}-${rule.to_port}-${rule.rule_num}" => rule
  }


  # SSM Endpoints (Systems Session Manager)
  ssm_endpoints = [
    "com.amazonaws.eu-west-2.ec2",
    "com.amazonaws.eu-west-2.ec2messages",
    "com.amazonaws.eu-west-2.ssm",
    "com.amazonaws.eu-west-2.ssmmessages"
  ]
  ssm_endpoints_expanded = flatten([
    for app_key, app in var.subnet_sets : [
      for key, endpoint in local.ssm_endpoints : {
        app_name = app_key
        endpoint = endpoint
      }
    ]
  ])
  expanded_ssm_endpoints_with_keys = {
    for item in local.ssm_endpoints_expanded :
    "${item.app_name}-${item.endpoint}" => item
  }

}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags_common,
    {
      Name = var.tags_prefix
    },
  )
}

# Add subnet-set CIDR's to VPC
resource "aws_vpc_ipv4_cidr_block_association" "subnet_sets" {
  for_each = tomap(var.subnet_sets)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value
}

# Add protected CIDR to VPC
resource "aws_vpc_ipv4_cidr_block_association" "protected" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.protected
}

# VPC: Subnet per type, per availability zone
resource "aws_subnet" "subnets" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.subnet_sets]

  for_each = tomap(local.all_subnets_with_keys)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Protected Subnets
resource "aws_subnet" "protected" {
  depends_on = [aws_vpc_ipv4_cidr_block_association.protected]

  for_each = tomap(local.expanded_protected_subnets_with_keys)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# NACLs
resource "aws_network_acl" "default" {
  depends_on = [aws_subnet.subnets]

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

resource "aws_network_acl_rule" "allow_local_network_egress" {
  for_each = toset(local.distinct_subnets_by_key_type)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.subnet_sets[split("-", each.value)[0]]
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

resource "aws_network_acl_rule" "allow_vpc_endpoint_ingress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 220
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.protected
}

resource "aws_network_acl_rule" "allow_vpc_endpoint_egress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 220
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.protected
}

resource "aws_network_acl_rule" "allow_internet_egress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 910
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "allow_internet_ingress" {
  for_each = toset(local.distinct_subnets_by_key_type_excluding_data)

  network_acl_id = aws_network_acl.default[each.value].id
  rule_number    = 910
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl" "subnets_protected" {
  depends_on = [aws_subnet.protected]

  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.protected["protected-${az}"].id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-Protected"
    },
  )
}
# add rules to protected subnets
resource "aws_network_acl_rule" "base_nacl_rules_for_protected" {
  for_each = local.protected_nacl_rules_with_keys

  network_acl_id = aws_network_acl.subnets_protected.id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# add rules to protected subnets nacl for all local subnet-sets
resource "aws_network_acl_rule" "local_nacl_rules_for_protected_ingress" {
  for_each = {
    for index, subnet in keys(var.subnet_sets) :
    index => var.subnet_sets[subnet]
  }

  network_acl_id = aws_network_acl.subnets_protected.id
  rule_number    = ((each.key + 1) * 10) + 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = "443"
  to_port        = "443"
}
resource "aws_network_acl_rule" "local_nacl_rules_for_protected_egress" {
  for_each = {
    for index, subnet in keys(var.subnet_sets) :
    index => var.subnet_sets[subnet]
  }

  network_acl_id = aws_network_acl.subnets_protected.id
  rule_number    = ((each.key + 1) * 10) + 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value
  from_port      = "443"
  to_port        = "443"
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


resource "aws_route_table" "protected" {

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-protected"
    }
  )
}
resource "aws_route_table_association" "protected" {
  for_each = aws_subnet.protected

  subnet_id      = each.value.id
  route_table_id = aws_route_table.protected.id
}


# SSM Security Groups
resource "aws_security_group" "ssm_endpoints" {
  for_each = var.subnet_sets

  name        = "${each.key}_SSM"
  description = "Control SSM traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${each.key}_SSM"
    }
  )
}
resource "aws_security_group_rule" "ssm-ingress1" {
  for_each = var.subnet_sets

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.ssm_endpoints[each.key].id

}
# # SSM Endpoints
resource "aws_vpc_endpoint" "ssm" {
  for_each = toset(local.ssm_endpoints)

  vpc_id            = aws_vpc.vpc.id
  service_name      = each.value
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    for az in local.availability_zones :
    aws_subnet.protected["protected-${az}"].id
  ]
  security_group_ids = [
    for key, value in var.subnet_sets :
    aws_security_group.ssm_endpoints[key].id
  ]

  private_dns_enabled = true

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}


################  S3 enpoint required ################

# # Bastion Security Groups
# resource "aws_security_group" "bastion" {
#   for_each = var.subnet_sets

#   name        = "${each.key}_Bastion"
#   description = "Control Bastion traffic"
#   vpc_id            = aws_vpc.vpc.id

#   tags = merge(
#     var.tags_common,
#     {
#       Name = "${each.key}_Bastion"
#     }
#   )
# }

#   egress {
#     from_port   = 0
#     to_port     = 1024
#     protocol    = "TCP"
#     cidr_blocks = [each.value]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 1024
#     protocol    = "UDP"
#     cidr_blocks = [each.value]
#   }
