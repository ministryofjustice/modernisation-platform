# R53 Resolver Logs

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

| Name                                                                                                                                                                                | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                                   | resource |
| [aws_route53_resolver_query_log_config.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config)                         | resource |
| [aws_route53_resolver_query_log_config_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config_association) | resource |

## Inputs

| Name                                                               | Description                     | Type          | Default | Required |
| ------------------------------------------------------------------ | ------------------------------- | ------------- | ------- | :------: |
| <a name="input_tags_common"></a> [tags_common](#input_tags_common) | Map of tags                     | `map(string)` | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                | VPC ID to turn on resolver logs | `string`      | n/a     |   yes    |
| <a name="input_vpc_name"></a> [vpc_name](#input_vpc_name)          | VPC name used in title of logs  | `string`      | n/a     |   yes    |

## Outputs

| Name                                                                                               | Description |
| -------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_r53_resolver_log_name"></a> [r53_resolver_log_name](#output_r53_resolver_log_name) | n/a         |

<!-- END_TF_DOCS -->
