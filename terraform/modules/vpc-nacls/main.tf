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
