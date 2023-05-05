resource "aws_networkfirewall_firewall" "inline_inspection" {
  name                = format("%s-inline-inspection", var.tags_prefix)
  firewall_policy_arn = var.fw_policy_arn
  vpc_id              = aws_vpc.main.id
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

module "inline_inspection_logging" {
  source                    = "../firewall-logging"
  cloudwatch_log_group_name = format("fw-%s-logs", aws_networkfirewall_firewall.inline_inspection.name)
  fw_arn                    = aws_networkfirewall_firewall.inline_inspection.arn
  tags                      = var.tags_common
}