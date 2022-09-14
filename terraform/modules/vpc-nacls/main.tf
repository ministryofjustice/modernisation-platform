resource "aws_network_acl" "general-public" {
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.public_subnet_ids
  tags = merge(
    { "Name" = format("%s-public-nacl", var.tags_prefix) },
    var.tags
  )
}

resource "aws_network_acl" "general-private" {
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.private_subnet_ids
  tags = merge(
    { "Name" = format("%s-private-nacl", var.tags_prefix) },
    var.tags
  )
}

resource "aws_network_acl" "general-data" {
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.data_subnet_ids
  tags = merge(
    { "Name" = format("%s-data-nacl", var.tags_prefix) },
    var.tags
  )
}

resource "aws_network_acl" "protected" {
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.protected_subnet_ids
  tags = merge(
    { "Name" = format("%s-protected-nacl", var.tags_prefix) },
    var.tags
  )
}

resource "aws_network_acl_rule" "data_subnet_static_rules" {
  for_each       = local.static_acl_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  network_acl_id = aws_network_acl.general-data.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
}

resource "aws_network_acl_rule" "private_subnet_static_rules" {
  for_each       = local.static_acl_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  network_acl_id = aws_network_acl.general-private.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
}

resource "aws_network_acl_rule" "public_subnet_static_rules" {
  for_each       = local.static_acl_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  network_acl_id = aws_network_acl.general-public.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
}

resource "aws_network_acl_rule" "public_subnet_internet_access_rules" {
  for_each       = local.public_access_acl_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  from_port      = each.value.from_port
  network_acl_id = aws_network_acl.general-public.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "protected_subnet_vpc_access_rules" {
  for_each       = local.endpoint_access_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  from_port      = each.value.from_port
  network_acl_id = aws_network_acl.protected.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
  to_port        = each.value.to_port
}

# Data subnet dynamic rules
resource "aws_network_acl_rule" "data_subnet_dynamic_vpc_ingress_rules" {
  for_each       = { for i, v in local.external_vpc_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-data.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 2000
}

resource "aws_network_acl_rule" "data_subnet_dynamic_vpc_egress_rules" {
  for_each       = { for i, v in local.external_vpc_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-data.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 2000
}

resource "aws_network_acl_rule" "data_subnet_dynamic_range_ingress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-data.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 5000
}

resource "aws_network_acl_rule" "data_subnet_dynamic_range_egress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-data.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 5000
}

# Private subnet dynamic rules
resource "aws_network_acl_rule" "private_subnet_dynamic_vpc_ingress_rules" {
  for_each       = { for i, v in local.external_vpc_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 2000
}

resource "aws_network_acl_rule" "private_subnet_dynamic_vpc_egress_rules" {
  for_each       = { for i, v in local.external_vpc_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 2000
}

resource "aws_network_acl_rule" "private_subnet_dynamic_range_ingress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 5000
}

resource "aws_network_acl_rule" "private_subnet_dynamic_range_egress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 5000
}

# Public subnet dynamic rules
resource "aws_network_acl_rule" "public_subnet_dynamic_vpc_ingress_rules" {
  for_each       = { for i, v in local.external_vpc_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 2000
}

resource "aws_network_acl_rule" "public_subnet_dynamic_vpc_egress_rules" {
  for_each       = { for i, v in local.external_vpc_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 2000
}

resource "aws_network_acl_rule" "public_subnet_dynamic_range_ingress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 5000
}

resource "aws_network_acl_rule" "public_subnet_dynamic_range_egress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 5000
}