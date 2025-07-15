# Transit Gateway EC2 Attachment

Terraform module for creating Transit Gateway EC2 attachments.

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0   |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.0   |
| <a name="requirement_time"></a> [time](#requirement_time)                | >= 0.9.1 |

## Providers

| Name                                                                                                                  | Version  |
| --------------------------------------------------------------------------------------------------------------------- | -------- |
| <a name="provider_aws.transit-gateway-host"></a> [aws.transit-gateway-host](#provider_aws.transit-gateway-host)       | ~> 6.0   |
| <a name="provider_aws.transit-gateway-tenant"></a> [aws.transit-gateway-tenant](#provider_aws.transit-gateway-tenant) | ~> 6.0   |
| <a name="provider_time"></a> [time](#provider_time)                                                                   | >= 0.9.1 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                               | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_ec2_tag.retag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag)                                                                           | resource    |
| [aws_ec2_transit_gateway_route_table_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource    |
| [aws_ec2_transit_gateway_vpc_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment)                   | resource    |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                                                                   | resource    |
| [aws_ec2_transit_gateway_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_route_table)                      | data source |

## Inputs

| Name                                                                                    | Description                                   | Type           | Default | Required |
| --------------------------------------------------------------------------------------- | --------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids)                         | Subnet IDs to attach to the Transit Gateway   | `list(string)` | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                           | Tags to attach to resources, where applicable | `map(any)`     | n/a     |   yes    |
| <a name="input_transit_gateway_id"></a> [transit_gateway_id](#input_transit_gateway_id) | Transit Gateway ID to attach to               | `string`       | n/a     |   yes    |
| <a name="input_type"></a> [type](#input_type)                                           | Type of Transit Gateway to attach to          | `string`       | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                     | VPC ID to attach to the Transit Gateway       | `string`       | n/a     |   yes    |
| <a name="input_vpc_name"></a> [vpc_name](#input_vpc_name)                               | VPC name (used for tagging)                   | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                                      | Description |
| ----------------------------------------------------------------------------------------- | ----------- |
| <a name="output_tgw_route_table"></a> [tgw_route_table](#output_tgw_route_table)          | n/a         |
| <a name="output_tgw_vpc_attachment"></a> [tgw_vpc_attachment](#output_tgw_vpc_attachment) | n/a         |

<!-- END_TF_DOCS -->
