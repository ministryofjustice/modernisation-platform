resource "aws_networkfirewall_firewall" "inline_inspection" {
  name                = replace(format("%s-inline-inspection", var.tags_prefix), "/_/", "-")
  firewall_policy_arn = module.inline_inspection_policy.fw_policy_arn
  vpc_id              = aws_vpc.main.id
  delete_protection   = var.fw_delete_protection
  encryption_configuration {
    type   = "CUSTOMER_KMS"
    key_id = var.fw_kms_arn
  }
  dynamic "subnet_mapping" {
    for_each = aws_subnet.inspection
    content {
      subnet_id = subnet_mapping.value.id
    }
  }
  tags = merge(
    var.tags_common,
    { Name = format("%s-inline-inspection", var.tags_prefix) }
  )
}

module "inline_inspection_policy" {
  source                 = "../../modules/firewall-policy"
  fw_rulegroup_capacity  = "10000"
  fw_kms_arn             = var.fw_kms_arn
  fw_policy_name         = format("%s-inline-fw-policy", var.tags_prefix)
  fw_rulegroup_name      = format("%s-inline-fw-rulegroup", var.tags_prefix)
  fw_fqdn_rulegroup_name = format("%s-inlinefw-fqdn-rulegroup", var.tags_prefix)
  fw_allowed_domains     = var.fw_allowed_domains
  fw_home_net_ips        = var.fw_home_net_ips
  fw_managed_rule_groups = var.fw_managed_rule_groups
  rules                  = var.fw_rules

  tags = merge(
    var.tags_common,
    { Name = format("%s-inline-fw-policy", var.tags_prefix) }
  )
}

module "inline_inspection_logging" {
  source                    = "../firewall-logging"
  cloudwatch_log_group_name = format("fw-%s-logs", aws_networkfirewall_firewall.inline_inspection.name)
  fw_arn                    = aws_networkfirewall_firewall.inline_inspection.arn
  fw_name                   = aws_networkfirewall_firewall.inline_inspection.name
  tags                      = var.tags_common
}

module "firehose_delivery_stream" {
  source                  = "../../modules/firehose"
  resource_prefix         = "${var.tags_prefix}-firewall"
  log_group_name          = module.inline_inspection_logging.cloudwatch_log_group_name
  tags                    = var.tags_common
  xsiam_endpoint          = var.xsiam_firewall_endpoint
  xsiam_secret            = var.xsiam_firewall_secret
}