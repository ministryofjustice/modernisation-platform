<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0  |
| <a name="requirement_random"></a> [random](#requirement_random)          | ~> 3.4  |

## Providers

| Name                                                      | Version |
| --------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)          | ~> 5.0  |
| <a name="provider_random"></a> [random](#provider_random) | ~> 3.4  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                    | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_networkfirewall_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource    |
| [aws_networkfirewall_rule_group.fqdn-stateful](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group)  | resource    |
| [aws_networkfirewall_rule_group.stateful](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group)       | resource    |
| [random_id.policy_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)                                                | resource    |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                             | data source |

## Inputs

| Name                                                                                                            | Description                                                                                                                                              | Type           | Default   | Required |
| --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | --------- | :------: |
| <a name="input_fw_allowed_domains"></a> [fw_allowed_domains](#input_fw_allowed_domains)                         | A list of domain names that will be added to an allow list rule                                                                                          | `list(string)` | n/a       |   yes    |
| <a name="input_fw_fqdn_rulegroup_capacity"></a> [fw_fqdn_rulegroup_capacity](#input_fw_fqdn_rulegroup_capacity) | rule group capacity for FQDN rule group                                                                                                                  | `string`       | `"3000"`  |    no    |
| <a name="input_fw_fqdn_rulegroup_name"></a> [fw_fqdn_rulegroup_name](#input_fw_fqdn_rulegroup_name)             | n/a                                                                                                                                                      | `string`       | n/a       |   yes    |
| <a name="input_fw_home_net_ips"></a> [fw_home_net_ips](#input_fw_home_net_ips)                                  | A list of VPC cidr ranges that will be added to the HOME_NET for VPC scanning                                                                            | `list(string)` | n/a       |   yes    |
| <a name="input_fw_kms_arn"></a> [fw_kms_arn](#input_fw_kms_arn)                                                 | ARN of KMS key used for encryption at rest                                                                                                               | `string`       | n/a       |   yes    |
| <a name="input_fw_managed_rule_groups"></a> [fw_managed_rule_groups](#input_fw_managed_rule_groups)             | Names of AWS managed rule groups from <https://docs.aws.amazon.com/network-firewall/latest/developerguide/aws-managed-rule-groups-threat-signature.html> | `list(string)` | `[]`      |    no    |
| <a name="input_fw_policy_name"></a> [fw_policy_name](#input_fw_policy_name)                                     | n/a                                                                                                                                                      | `string`       | n/a       |   yes    |
| <a name="input_fw_rulegroup_capacity"></a> [fw_rulegroup_capacity](#input_fw_rulegroup_capacity)                | n/a                                                                                                                                                      | `string`       | `"10000"` |    no    |
| <a name="input_fw_rulegroup_name"></a> [fw_rulegroup_name](#input_fw_rulegroup_name)                            | n/a                                                                                                                                                      | `string`       | n/a       |   yes    |
| <a name="input_ip_sets"></a> [ip_sets](#input_ip_sets)                                                          | A map of lists for firewall IP sets.                                                                                                                     | `map(any)`     | `{}`      |    no    |
| <a name="input_port_sets"></a> [port_sets](#input_port_sets)                                                    | A map of lists for firewall port sets.                                                                                                                   | `map(any)`     | `{}`      |    no    |
| <a name="input_rules"></a> [rules](#input_rules)                                                                | A map of values supplied to create firewall rules                                                                                                        | `map(any)`     | n/a       |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                   | A map of keys and values used to create resource metadata tags                                                                                           | `map(any)`     | n/a       |   yes    |

## Outputs

| Name                                                                                      | Description |
| ----------------------------------------------------------------------------------------- | ----------- |
| <a name="output_fw_fqdn_policy_arn"></a> [fw_fqdn_policy_arn](#output_fw_fqdn_policy_arn) | n/a         |
| <a name="output_fw_policy_arn"></a> [fw_policy_arn](#output_fw_policy_arn)                | n/a         |

<!-- END_TF_DOCS -->
