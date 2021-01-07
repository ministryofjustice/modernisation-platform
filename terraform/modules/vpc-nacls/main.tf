locals {

  nacl_base = [
    for key, value in var.nacl_config : {
      name        = value.app
      cidr_block  = value.cidr_block
      egress      = value.egress
      protocol    = value.protocol
      rule_action = value.rule_action
      rule_number = value.rule_number
      subnet_type = value.subnet_type
    }
  ]

  expanded_nacl_base_with_keys = {
    for data in local.nacl_base :
    "${data.name}-${data.cidr_block}-${data.egress}-${data.subnet_type}" => data
  }

  expanded_nacl_refs_with_keys = {
    for data in var.nacl_refs :
    data.name => data
  }
}

resource "aws_network_acl_rule" "custom_nacl_deployment" {
  for_each = local.expanded_nacl_base_with_keys

  network_acl_id = local.expanded_nacl_refs_with_keys["${var.tags_prefix}-${each.value.name}-${each.value.subnet_type}"].id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
}
