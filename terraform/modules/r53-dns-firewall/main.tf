# R53 Resolver DNS Firewall Resources - created on a per-VPC basis

resource "aws_route53_resolver_firewall_rule_group" "this" {
  name = "${var.tags_prefix}-r53-dns-firewall-rule-group"
  tags = var.tags_common
}

resource "aws_route53_resolver_firewall_domain_list" "allow" {
  name    = "${var.tags_prefix}-allow-domain-list"
  domains = [for domain in var.allowed_domains : "${domain}."]
  tags    = var.tags_common
}

resource "aws_route53_resolver_firewall_domain_list" "block" {
  name    = "${var.tags_prefix}-block-domain-list"
  domains = [for domain in var.blocked_domains : "${domain}."]
  tags    = var.tags_common
}

# Default rule to BLOCK based on AWS-managed bad domain lists - see https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-managed-domain-lists.html
data "external" "aws_managed_domain_lists" {
  program = ["bash", "${path.module}/fetch-aws-managed-domain-lists.sh"]
}
resource "aws_route53_resolver_firewall_rule" "default_alert" {
  for_each                = data.external.aws_managed_domain_lists.result
  action                  = "BLOCK"
  block_response          = var.block_response
  firewall_domain_list_id = each.value
  priority                = each.key == "AWSManagedDomainsAggregateThreatList" ? 2 : each.key == "AWSManagedDomainsMalwareDomainList" ? 3 : each.key == "AWSManagedDomainsBotnetCommandandControl" ? 4 : 5
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  name                    = "Alert_${each.key}"
}

resource "aws_route53_resolver_firewall_rule" "allow" {
  action                  = "ALLOW"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.allow.id
  priority                = 1
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  name                    = "Allow_${var.tags_prefix}_domain_list"
}

resource "aws_route53_resolver_firewall_rule" "block" {
  action                  = "BLOCK"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.block.id
  priority                = 6
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  name                    = "Block_${var.tags_prefix}_domain_list"
  block_response          = var.block_response # defaults to NXDOMAIN
}

resource "aws_route53_resolver_firewall_rule_group_association" "this" {
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.this.id
  vpc_id                 = var.vpc_id
  priority               = var.association_priority
  name                   = "${var.tags_prefix}-association"
  tags                   = var.tags_common
}