# VPC Transit Gateway Routes

Terraform module for creating core VPC Transit Gateway Routes.

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 4.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 4.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                   | Type     |
| ---------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_route.private_transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name                                                                                    | Description | Type     | Default | Required |
| --------------------------------------------------------------------------------------- | ----------- | -------- | ------- | :------: |
| <a name="input_route_table_ids"></a> [route_table_ids](#input_route_table_ids)          | n/a         | `any`    | n/a     |   yes    |
| <a name="input_transit_gateway_id"></a> [transit_gateway_id](#input_transit_gateway_id) | n/a         | `string` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
