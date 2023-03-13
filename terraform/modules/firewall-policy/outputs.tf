output "fw_policy_arn" {
  value = aws_networkfirewall_firewall_policy.main.arn
}
output "fw_fqdn_policy_arn" {
  value = aws_networkfirewall_rule_group.fqdn-stateful.arn
}