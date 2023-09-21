data "aws_region" "current" {}

resource "random_id" "policy_id" {
  byte_length = 2
}

resource "aws_networkfirewall_firewall_policy" "main" {
  name = replace(format("%s-%s", var.fw_policy_name, random_id.policy_id.id), "/-|_/", "")
  encryption_configuration {
    type   = "CUSTOMER_KMS"
    key_id = var.fw_kms_arn
  }
  firewall_policy {
    stateful_engine_options {
      rule_order = "DEFAULT_ACTION_ORDER"
    }
    dynamic "stateful_rule_group_reference" {
      #for_each = toset(var.fw_managed_rule_groups)
      for_each = length(var.fw_managed_rule_groups) > 0 ? toset(var.fw_managed_rule_groups) : []
      content {
        resource_arn = format("arn:aws:network-firewall:%s:aws-managed:stateful-rulegroup/%s", data.aws_region.current.name, stateful_rule_group_reference.key)
      }
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.fqdn-stateful.arn
    }
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:drop"]
  }
  lifecycle {
    create_before_destroy = false
  }
  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "stateful" {
  capacity = var.fw_rulegroup_capacity
  encryption_configuration {
    type   = "CUSTOMER_KMS"
    key_id = var.fw_kms_arn
  }
  name = replace(format("%s-%s", var.fw_rulegroup_name, random_id.policy_id.id), "/-|_/", "")
  type = "STATEFUL"

  rule_group {
    stateful_rule_options {
      rule_order = "DEFAULT_ACTION_ORDER"
    }
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
            keyword  = "sid"
            settings = [format("%s", index(keys(var.rules), stateful_rule.key) + 1)]
          }
        }
      }
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_networkfirewall_rule_group" "fqdn-stateful" {
  capacity = var.fw_fqdn_rulegroup_capacity
  encryption_configuration {
    type   = "CUSTOMER_KMS"
    key_id = var.fw_kms_arn
  }
  name = replace(format("%s-%s", var.fw_fqdn_rulegroup_name, random_id.policy_id.id), "/-|_/", "")
  type = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = var.fw_home_net_ips
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.fw_allowed_domains
      }
    }
  }
}

