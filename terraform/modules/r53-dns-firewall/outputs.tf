output "firewall_rule_group_id" {
  description = "The ID of the DNS Firewall rule group"
  value       = aws_route53_resolver_firewall_rule_group.this.id
}