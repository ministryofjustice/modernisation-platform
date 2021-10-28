# VPC Transit Gateway Routes

Terraform module for creating core VPC Transit Gateway Return Routes.

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.47.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_route.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_route.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC name used to lookup routing tables | `string` | n/a | yes |
| <a name="input_vpc_cidr_range"></a> [vpc\_cidr\_range](#input\_subnet\_sets) | VPC CIDR range to add to Transit Gateway routing table | `string` | n/a | yes |
| <a name="input_tgw_vpc_attachment"></a> [tgw\_id](#input\_tgw\_vpc\_attachment) | Transit Gateway VPC attachment ID | `string` | n/a | yes |
| <a name="input_tgw_route_table"></a> [tgw\_route\_table](#input\_tgw\_route\_table) | Transit Gateway route table ID | `string` | n/a | yes |
| <a name="input_tgw_id"></a> [tgw\_vpc\_attachment](#input\_tgw\_id) | Transit Gateway ID | `string` | n/a | yes |

## Outputs

No outputs.

<!--- END_TF_DOCS --->

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
