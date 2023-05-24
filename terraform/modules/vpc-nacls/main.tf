resource "aws_network_acl" "general-public" {
  #checkov:skip=CKV2_AWS_1:These are attached to a subnet and a vpc
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.public_subnet_ids
  tags = merge(
    { "Name" = format("%s-public-nacl", var.tags_prefix) },
    var.tags
  )
}
resource "aws_network_acl" "general-private" {
  #checkov:skip=CKV2_AWS_1:These are attached to a subnet and a vpc
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.private_subnet_ids
  tags = merge(
    { "Name" = format("%s-private-nacl", var.tags_prefix) },
    var.tags
  )
}
resource "aws_network_acl" "general-data" {
  #checkov:skip=CKV2_AWS_1:These are attached to a subnet and a vpc
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.data_subnet_ids
  tags = merge(
    { "Name" = format("%s-data-nacl", var.tags_prefix) },
    var.tags
  )
}
resource "aws_network_acl" "protected" {
  #checkov:skip=CKV2_AWS_1:These are attached to a subnet and a vpc
  vpc_id     = data.aws_vpc.current.id
  subnet_ids = local.protected_subnet_ids
  tags = merge(
    { "Name" = format("%s-protected-nacl", var.tags_prefix) },
    var.tags
  )
}

#tfsec:ignore:aws-vpc-no-excessive-port-access tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "data_subnet_static_rules" {
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
  for_each       = local.static_acl_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  from_port      = each.value.from_port != null ? each.value.from_port : null
  network_acl_id = aws_network_acl.general-data.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
  to_port        = each.value.to_port != null ? each.value.to_port : null
}

#tfsec:ignore:aws-vpc-no-excessive-port-access tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "private_subnet_static_rules" {
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
  for_each       = local.static_acl_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  from_port      = each.value.from_port != null ? each.value.from_port : null
  network_acl_id = aws_network_acl.general-private.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
  to_port        = each.value.to_port != null ? each.value.to_port : null
}

#tfsec:ignore:aws-vpc-no-excessive-port-access tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "public_subnet_static_rules" {
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
  for_each       = local.static_acl_rules
  cidr_block     = each.value.cidr_block
  egress         = each.value.egress
  from_port      = each.value.from_port != null ? each.value.from_port : null
  network_acl_id = aws_network_acl.general-public.id
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  rule_number    = each.value.rule_number
  to_port        = each.value.to_port != null ? each.value.to_port : null
}

#tfsec:ignore:aws-vpc-no-excessive-port-access tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "public_subnet_internet_access_rules" {
  #checkov:skip=CKV_AWS_231:Verified - these rules are reasonable
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
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
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
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-data.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 6000
}

resource "aws_network_acl_rule" "data_subnet_dynamic_range_egress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-data.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 6000
}

# Private subnet dynamic rules
resource "aws_network_acl_rule" "private_subnet_dynamic_vpc_ingress_rules" {
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
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
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 6000
}

resource "aws_network_acl_rule" "private_subnet_dynamic_range_egress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-private.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 6000
}

# Public subnet dynamic rules
resource "aws_network_acl_rule" "public_subnet_dynamic_vpc_ingress_rules" {
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
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
  #checkov:skip=CKV_AWS_352:Verified - these rules are reasonable
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = false
  network_acl_id = aws_network_acl.general-public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 6000
}

resource "aws_network_acl_rule" "public_subnet_dynamic_range_egress_rules" {
  for_each       = { for i, v in local.external_range_cidrs : i => v }
  cidr_block     = each.value.cidr_block
  egress         = true
  network_acl_id = aws_network_acl.general-public.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = (each.key * 100) + 6000
}