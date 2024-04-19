# VPC Hub

Terraform module to create a multi-tiered, multi-AZ VPC for use with Transit Gateway.

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                               | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)               | resource    |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group)           | resource    |
| [aws_eip.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                  | resource    |
| [aws_flow_log.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log)                                    | resource    |
| [aws_internet_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                       | resource    |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                  | resource    |
| [aws_network_acl.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                                    | resource    |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                                 | resource    |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                                  | resource    |
| [aws_network_acl.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)                         | resource    |
| [aws_network_acl_rule.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)                          | resource    |
| [aws_network_acl_rule.data-local-egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)             | resource    |
| [aws_network_acl_rule.data-local-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)            | resource    |
| [aws_network_acl_rule.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)                       | resource    |
| [aws_network_acl_rule.private-local-egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)          | resource    |
| [aws_network_acl_rule.private-local-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)         | resource    |
| [aws_network_acl_rule.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)                        | resource    |
| [aws_network_acl_rule.public-local-egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)           | resource    |
| [aws_network_acl_rule.public-local-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)          | resource    |
| [aws_network_acl_rule.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)               | resource    |
| [aws_network_acl_rule.transit-gateway-local-egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule)  | resource    |
| [aws_network_acl_rule.transit-gateway-local-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource    |
| [aws_route.data-nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                            | resource    |
| [aws_route.data-tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                            | resource    |
| [aws_route.private-nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                         | resource    |
| [aws_route.private-tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                         | resource    |
| [aws_route.public-internet-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                             | resource    |
| [aws_route.public_mp_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                      | resource    |
| [aws_route.public_mp_dev-test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                  | resource    |
| [aws_route.public_mp_prod-preprod](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                              | resource    |
| [aws_route.transit-gateway-nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                 | resource    |
| [aws_route.transit-gateway-tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)                                 | resource    |
| [aws_route_table.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                    | resource    |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                 | resource    |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                  | resource    |
| [aws_route_table.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                         | resource    |
| [aws_route_table_association.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)            | resource    |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)         | resource    |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)          | resource    |
| [aws_route_table_association.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource    |
| [aws_subnet.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                              | resource    |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                           | resource    |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                            | resource    |
| [aws_subnet.transit-gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                   | resource    |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                 | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)              | data source |

## Inputs

| Name                                                                                             | Description                                               | Type       | Default  | Required |
| ------------------------------------------------------------------------------------------------ | --------------------------------------------------------- | ---------- | -------- | :------: |
| <a name="input_gateway"></a> [gateway](#input_gateway)                                           | Type of gateway to use for environment                    | `string`   | `"none"` |    no    |
| <a name="input_tags_common"></a> [tags_common](#input_tags_common)                               | Ministry of Justice required tags                         | `map(any)` | n/a      |   yes    |
| <a name="input_tags_prefix"></a> [tags_prefix](#input_tags_prefix)                               | Prefix for name tags, e.g. "live_data"                    | `string`   | n/a      |   yes    |
| <a name="input_transit_gateway_id"></a> [transit_gateway_id](#input_transit_gateway_id)          | n/a                                                       | `string`   | `""`     |    no    |
| <a name="input_vpc_cidr"></a> [vpc_cidr](#input_vpc_cidr)                                        | CIDR range for the VPC                                    | `string`   | n/a      |   yes    |
| <a name="input_vpc_flow_log_iam_role"></a> [vpc_flow_log_iam_role](#input_vpc_flow_log_iam_role) | VPC Flow Log IAM role ARN for VPC Flow Logs to CloudWatch | `string`   | n/a      |   yes    |

## Outputs

| Name                                                                                                        | Description                                                                                 |
| ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| <a name="output_non_tgw_subnet_ids"></a> [non_tgw_subnet_ids](#output_non_tgw_subnet_ids)                   | Non-Transit Gateway subnet IDs (public, private, data)                                      |
| <a name="output_non_tgw_subnet_ids_map"></a> [non_tgw_subnet_ids_map](#output_non_tgw_subnet_ids_map)       | Map of subnet ids, with keys being the subnet types and values being the list of subnet ids |
| <a name="output_private_route_tables"></a> [private_route_tables](#output_private_route_tables)             | Private route table keys and IDs                                                            |
| <a name="output_private_route_tables_map"></a> [private_route_tables_map](#output_private_route_tables_map) | Private route table keys and IDs, as a map organised by type                                |
| <a name="output_public_igw_route"></a> [public_igw_route](#output_public_igw_route)                         | Public Internet Gateway route                                                               |
| <a name="output_public_route_tables"></a> [public_route_tables](#output_public_route_tables)                | Public route tables                                                                         |
| <a name="output_tgw_subnet_ids"></a> [tgw_subnet_ids](#output_tgw_subnet_ids)                               | Transit Gateway subnet IDs                                                                  |
| <a name="output_vpc_cidr_block"></a> [vpc_cidr_block](#output_vpc_cidr_block)                               | VPC CIDR block                                                                              |
| <a name="output_vpc_cloudwatch_name"></a> [vpc_cloudwatch_name](#output_vpc_cloudwatch_name)                | n/a                                                                                         |
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id)                                                       | VPC ID                                                                                      |

<!-- END_TF_DOCS -->
