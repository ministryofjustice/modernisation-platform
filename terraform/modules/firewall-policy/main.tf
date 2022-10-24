resource "aws_networkfirewall_firewall_policy" "main" {
  name = var.fw_policy_name
  firewall_policy {
    stateful_engine_options {
      rule_order = "STRICT"
    }
    stateful_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.stateful.arn
    }
    stateless_default_actions          = ["aws:pass"]
    stateless_fragment_default_actions = ["aws:drop"]
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "stateful" {
  capacity = var.fw_rulegroup_capacity
  name     = var.fw_rulegroup_name
  type     = "STATEFUL"

  rule_group {
    rules_source {
      dynamic "stateful_rule" {
        for_each = var.rules
        content {
          action = stateful_rule.value.action
          header {
            destination      = stateful_rule.value.destination_ip
            destination_port = stateful_rule.value.destination_port
            direction        = "ANY"
            protocol         = stateful_rule.value.protocol
            source_port      = "ANY"
            source           = stateful_rule.value.source_ip
          }
          rule_option {
            keyword = format("sid:%s", random_integer.sid[stateful_rule.key].id)
          }
        }
      }
    }
  }
}

resource "random_integer" "sid" {
  for_each = var.rules
  max      = 1
  min      = 10000
}