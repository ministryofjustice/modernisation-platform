# VPC Transit Gateway Routing

Terraform module for creating core VPC Transit Gateway Routing

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_route_table"></a> [route\_table](#input\_route\_table) | Route Table | `any` | n/a | yes |
| <a name="input_subnet_sets"></a> [subnet\_sets](#input\_subnet\_sets) | Key, value map of subnet sets and their CIDR blocks | `map(any)` | n/a | yes |
| <a name="input_tgw_id"></a> [tgw\_id](#input\_tgw\_id) | Transit Gateway ID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->