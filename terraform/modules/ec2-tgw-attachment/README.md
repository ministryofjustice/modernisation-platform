# Transit Gateway EC2 Attachment

Terraform module for creating Transit Gateway EC2 attachments.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.transit-gateway-host"></a> [aws.transit-gateway-host](#provider\_aws.transit-gateway-host) | ~> 5.0 |
| <a name="provider_aws.transit-gateway-tenant"></a> [aws.transit-gateway-tenant](#provider\_aws.transit-gateway-tenant) | ~> 5.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_tag.retag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_transit_gateway_route_table_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_ec2_transit_gateway_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_transit_gateway_route_table) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs to attach to the Transit Gateway | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to attach to resources, where applicable | `map(any)` | n/a | yes |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | Transit Gateway ID to attach to | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | Type of Transit Gateway to attach to | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to attach to the Transit Gateway | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC name (used for tagging) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tgw_route_table"></a> [tgw\_route\_table](#output\_tgw\_route\_table) | n/a |
| <a name="output_tgw_vpc_attachment"></a> [tgw\_vpc\_attachment](#output\_tgw\_vpc\_attachment) | n/a |
<!-- END_TF_DOCS -->