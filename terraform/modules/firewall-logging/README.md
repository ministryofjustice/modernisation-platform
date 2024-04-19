# Firewall Logging

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0  |
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

| Name                                                                                                                                                                | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                   | resource |
| [aws_networkfirewall_logging_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration) | resource |
| [random_string.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                         | resource |

## Inputs

| Name                                                                                                         | Description                                                    | Type       | Default | Required |
| ------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- | ---------- | ------- | :------: |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#input_cloudwatch_log_group_name) | Name of CloudWatch log group to ship logs to                   | `string`   | n/a     |   yes    |
| <a name="input_fw_arn"></a> [fw_arn](#input_fw_arn)                                                          | ARN of firewall for logging configuration                      | `string`   | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                | A map of keys and values used to create resource metadata tags | `map(any)` | n/a     |   yes    |

## Outputs

| Name                                                                                                           | Description |
| -------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#output_cloudwatch_log_group_name) | n/a         |

<!-- END_TF_DOCS -->
