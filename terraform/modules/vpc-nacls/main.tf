locals {
  nacl_base = {
    for value in var.nacl_config :
    "${value.subnet_set}-${value.cidr_block}-${value.egress}-${value.subnet_type}" => {
      name        = value.subnet_set
      cidr_block  = value.cidr_block
      egress      = value.egress
      protocol    = value.protocol
      rule_action = value.rule_action
      rule_number = value.rule_number
      subnet_type = value.subnet_type
      from_port   = value.from_port
      to_port     = value.to_port
    }
  }
}

resource "aws_network_acl_rule" "custom_nacl_deployment" {
  for_each = local.nacl_base

  network_acl_id = var.nacl_refs["${var.tags_prefix}-${each.value.name}-${each.value.subnet_type}"].id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "open_endpoint_cidrs_for_data_subnets_egress" {
  for_each = { 
    for key, data in var.cidrs_for_s3_endpoints :
    "${data.name}-${key}" => data
  }
  network_acl_id = each.value.id
  rule_number    = each.value.cidr_index + 251
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = "443"
  to_port        = "443"
}

resource "aws_network_acl_rule" "open_endpoint_cidrs_for_data_subnets_ingress" {
  for_each = { 
    for key, data in var.cidrs_for_s3_endpoints :
    "${data.name}-${key}" => data
  }
  network_acl_id = each.value.id
  rule_number    = each.value.cidr_index + 251
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = "1024"
  to_port        = "65535"
}
