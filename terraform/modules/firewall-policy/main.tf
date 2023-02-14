resource "aws_networkfirewall_firewall_policy" "main" {
  name = replace(title(var.fw_policy_name), "/-|_/", "")
  firewall_policy {
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateful_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.stateful.arn
    }
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:drop"]
  }

  tags = var.tags
}

resource "aws_networkfirewall_rule_group" "stateful" {
  capacity = var.fw_rulegroup_capacity
  name     = replace(title(var.fw_rulegroup_name), "/-|_/", "")
  type     = "STATEFUL"

  rule_group {
    stateful_rule_options {
      rule_order = "STRICT_ORDER"
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
  capacity = 100
  name     = replace(title("FQDN${var.fw_rulegroup_name}"), "/-|_/", "")
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST"]
        targets              = var.list_of_allowed_domain
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