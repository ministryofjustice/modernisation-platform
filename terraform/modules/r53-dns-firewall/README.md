# R53 DNS Firewall

Terraform module used to create R53 DNS Firewall resources for Modernisation Platform VPCs. For more info see https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-overview.html

This module creates the following resources per VPC:

- a R53 Resolver Firewall Rule Group associated with the VPC
- a custom list of allowed and blocked domains which can be defined via the `allowed_domains` and `blocked_domains` inputs
- R53 Resolver Firewall Rules in the following priority:
  **1** - An allow rule for the `allowed_domains` list
  **2-5** - a set of rules that BLOCK any domains that match the [AWS-managed threat lists](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-managed-domain-lists.html)
  **6** - A Block rule for the `blocked_domains` list

# Example usage

```
locals {
  dns_firewall_allowed_domains = {
    core-vpc-production    = {}
    core-vpc-preproduction = {}
    core-vpc-test          = {}
    core-vpc-development   = {}
    core-vpc-sandbox = {
      garden-sandbox = ["good-domain.com"]
    }
  }
  dns_firewall_blocked_domains = {
    core-vpc-production    = {}
    core-vpc-preproduction = {}
    core-vpc-test          = {}
    core-vpc-development   = {}
    core-vpc-sandbox = {
      garden-sandbox = ["bad-domain.com"]
    }
  }
}

module "r53_dns_firewall" {
  for_each = local.vpcs[terraform.workspace]
  source   = "../../modules/r53-dns-firewall"

  vpc_id = module.vpc[each.key].vpc_id

  allowed_domains = lookup(local.dns_firewall_allowed_domains[terraform.workspace], each.key, [])
  blocked_domains = lookup(local.dns_firewall_blocked_domains[terraform.workspace], each.key, [])

  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]

  tags_prefix = each.key
  tags_common = local.tags
}
```

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_external"></a> [external](#provider\_external) | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_resolver_firewall_domain_list.allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list) | resource |
| [aws_route53_resolver_firewall_domain_list.block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_domain_list) | resource |
| [aws_route53_resolver_firewall_rule.allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule.block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule.default_alert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule) | resource |
| [aws_route53_resolver_firewall_rule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group) | resource |
| [aws_route53_resolver_firewall_rule_group_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule_group_association) | resource |
| [external_external.aws_managed_domain_lists](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | List of allowed domains | `list(string)` | `[]` | no |
| <a name="input_association_priority"></a> [association\_priority](#input\_association\_priority) | Priority of the firewall rule group association | `number` | `101` | no |
| <a name="input_block_response"></a> [block\_response](#input\_block\_response) | The way that you want DNS Firewall to block the request. Supported Valid values are NODATA, NXDOMAIN, or OVERRIDE | `string` | `"NXDOMAIN"` | no |
| <a name="input_blocked_domains"></a> [blocked\_domains](#input\_blocked\_domains) | List of blocked domains | `list(string)` | `[]` | no |
| <a name="input_pagerduty_integration_key"></a> [pagerduty\_integration\_key](#input\_pagerduty\_integration\_key) | The PagerDuty integration key | `string` | n/a | yes |
| <a name="input_tags_common"></a> [tags\_common](#input\_tags\_common) | Ministry of Justice required tags | `map(any)` | n/a | yes |
| <a name="input_tags_prefix"></a> [tags\_prefix](#input\_tags\_prefix) | Prefix for name tags, e.g. the name of the VPC for unique identification of resources | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to associate with the DNS Firewall rule group | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_rule_group_id"></a> [firewall\_rule\_group\_id](#output\_firewall\_rule\_group\_id) | The ID of the DNS Firewall rule group |
<!-- END_TF_DOCS -->
