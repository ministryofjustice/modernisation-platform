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

| Name                                                                                                           | Source                        | Version |
| -------------------------------------------------------------------------------------------------------------- | ----------------------------- | ------- |
| <a name="module_inline_inspection_logging"></a> [inline_inspection_logging](#module_inline_inspection_logging) | ../firewall-logging           | n/a     |
| <a name="module_inline_inspection_policy"></a> [inline_inspection_policy](#module_inline_inspection_policy)    | ../../modules/firewall-policy | n/a     |

## Resources

| Name                                                                                                                                                                            | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                               | resource    |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group)                                        | resource    |
| [aws_ec2_transit_gateway_vpc_attachment.attachments-inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource    |
| [aws_eip.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                                               | resource    |
| [aws_flow_log.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                                                                 | resource    |
| [aws_internet_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                                                     | resource    |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                                               | resource    |
| [aws_network_acl.inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                                                           | resource    |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                                                               | resource    |
| [aws_network_acl.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                                                      | resource    |
| [aws_network_acl_rule.inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)                                                 | resource    |
| [aws_network_acl_rule.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)                                                     | resource    |
| [aws_network_acl_rule.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)                                            | resource    |
| [aws_networkfirewall_firewall.inline_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall)                          | resource    |
| [aws_route.inspection-0-0-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                               | resource    |
| [aws_route.inspection-10-20-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                             | resource    |
| [aws_route.inspection-10-231-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                            | resource    |
| [aws_route.inspection-10-26-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                             | resource    |
| [aws_route.inspection-10-27-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                             | resource    |
| [aws_route.public-0-0-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                                   | resource    |
| [aws_route.public-10-20-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                                 | resource    |
| [aws_route.public-10-231-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                                | resource    |
| [aws_route.public-10-26-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                                 | resource    |
| [aws_route.public-10-27-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                                 | resource    |
| [aws_route.transit-gateway-0-0-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                          | resource    |
| [aws_route.transit-gateway-10-20-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                        | resource    |
| [aws_route.transit-gateway-10-231-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                       | resource    |
| [aws_route.transit-gateway-10-26-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                        | resource    |
| [aws_route.transit-gateway-10-27-0-0](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                                        | resource    |
| [aws_route_table.inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                                           | resource    |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                                               | resource    |
| [aws_route_table.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                                      | resource    |
| [aws_route_table_association.inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                                   | resource    |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                                       | resource    |
| [aws_route_table_association.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)                              | resource    |
| [aws_subnet.inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                                     | resource    |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                                         | resource    |
| [aws_subnet.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                                | resource    |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                                                 | resource    |
| [random_string.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                                     | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)                                           | data source |

## Inputs

| Name                                                                                                | Description                                                                                                                                              | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_application_name"></a> [application_name](#input_application_name)                   | Application name, eg `core-shared-services` or `core-network-services`                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_cloudwatch_kms_key_id"></a> [cloudwatch_kms_key_id](#input_cloudwatch_kms_key_id)    | Optional KMS key ID to use in encrypting VPC flow logs CloudWatch group.                                                                                 | `string`       | `""`    |    no    |
| <a name="input_fw_allowed_domains"></a> [fw_allowed_domains](#input_fw_allowed_domains)             | List of strings containing allowed domains                                                                                                               | `list(string)` | n/a     |   yes    |
| <a name="input_fw_delete_protection"></a> [fw_delete_protection](#input_fw_delete_protection)       | Boolean to enable or disable firewall deletion protection                                                                                                | `bool`         | `true`  |    no    |
| <a name="input_fw_home_net_ips"></a> [fw_home_net_ips](#input_fw_home_net_ips)                      | List of strings covering firewall HOME_NET values                                                                                                        | `list(string)` | n/a     |   yes    |
| <a name="input_fw_kms_arn"></a> [fw_kms_arn](#input_fw_kms_arn)                                     | KMS key ARN used for firewall encryption                                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_fw_managed_rule_groups"></a> [fw_managed_rule_groups](#input_fw_managed_rule_groups) | Names of AWS managed rule groups from <https://docs.aws.amazon.com/network-firewall/latest/developerguide/aws-managed-rule-groups-threat-signature.html> | `list(string)` | `[]`    |    no    |
| <a name="input_fw_rules"></a> [fw_rules](#input_fw_rules)                                           | JSON map of maps containing stateless firewall rules                                                                                                     | `map(any)`     | n/a     |   yes    |
| <a name="input_tags_common"></a> [tags_common](#input_tags_common)                                  | Ministry of Justice required tags                                                                                                                        | `map(any)`     | n/a     |   yes    |
| <a name="input_tags_prefix"></a> [tags_prefix](#input_tags_prefix)                                  | Prefix for name tags, e.g. "live_data"                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_transit_gateway_id"></a> [transit_gateway_id](#input_transit_gateway_id)             | n/a                                                                                                                                                      | `string`       | `""`    |    no    |
| <a name="input_vpc_cidr"></a> [vpc_cidr](#input_vpc_cidr)                                           | CIDR range for the VPC                                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_vpc_flow_log_iam_role"></a> [vpc_flow_log_iam_role](#input_vpc_flow_log_iam_role)    | VPC Flow Log IAM role ARN for VPC Flow Logs to CloudWatch                                                                                                | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                                                                       | Description |
| -------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_firewall"></a> [firewall](#output_firewall)                                                                | n/a         |
| <a name="output_fw_cloudwatch_name"></a> [fw_cloudwatch_name](#output_fw_cloudwatch_name)                                  | n/a         |
| <a name="output_internet_gateway"></a> [internet_gateway](#output_internet_gateway)                                        | n/a         |
| <a name="output_nat_gateway"></a> [nat_gateway](#output_nat_gateway)                                                       | n/a         |
| <a name="output_route_table_ids"></a> [route_table_ids](#output_route_table_ids)                                           | n/a         |
| <a name="output_subnet_attributes"></a> [subnet_attributes](#output_subnet_attributes)                                     | n/a         |
| <a name="output_transit_gateway_attachment_id"></a> [transit_gateway_attachment_id](#output_transit_gateway_attachment_id) | n/a         |
| <a name="output_vpc_cloudwatch_name"></a> [vpc_cloudwatch_name](#output_vpc_cloudwatch_name)                               | n/a         |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)                                                                      | n/a         |

<!-- END_TF_DOCS -->
