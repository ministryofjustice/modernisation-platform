resource "random_id" "policy_id" {
  byte_length = 2
}

resource "aws_networkfirewall_firewall_policy" "main" {
  name = replace(format("%s-%s", var.fw_policy_name, random_id.policy_id.id), "/-|_/", "")
  firewall_policy {
    stateful_engine_options {
      rule_order = "DEFAULT_ACTION_ORDER"
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
  name     = replace(format("%s-%s", var.fw_rulegroup_name, random_id.policy_id.id), "/-|_/", "")
  type     = "STATEFUL"

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
            keyword = format("sid:%s", index(keys(var.rules), stateful_rule.key) + 1)
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
  name     = replace(format("%s-%s", var.fw_fqdn_rulegroup_name, random_id.policy_id.id), "/-|_/", "")
  type     = "STATEFUL"
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
        target_types         = ["HTTP_HOST"]
        targets              = var.fw_allowed_domains
      }
    }
  }
}

resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = var.fw_arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.main.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "main" {
  #checkov:skip=CKV_AWS_158:Temporarily skip KMS encryption check while logging solution is being updated
  name              = var.cloudwatch_log_group_name
  retention_in_days = 365 # 0 = never expire
  tags              = var.tags
}