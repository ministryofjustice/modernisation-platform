<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firehose_delivery_stream"></a> [firehose\_delivery\_stream](#module\_firehose\_delivery\_stream) | ../../modules/firehose | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_networkfirewall_logging_configuration.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration) | resource |
| [random_string.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group to ship logs to | `string` | n/a | yes |
| <a name="input_fw_arn"></a> [fw\_arn](#input\_fw\_arn) | ARN of firewall for logging configuration | `string` | n/a | yes |
| <a name="input_fw_name"></a> [fw\_name](#input\_fw\_name) | Name of firewall to identify whether live or non-line | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of keys and values used to create resource metadata tags | `map(any)` | n/a | yes |
| <a name="input_xsiam_firewall_endpoint"></a> [xsiam\_firewall\_endpoint](#input\_xsiam\_firewall\_endpoint) | The http endpoint URL for the transfer of log data via firehose | `string` | n/a | yes |
| <a name="input_xsiam_firewall_secret"></a> [xsiam\_firewall\_secret](#input\_xsiam\_firewall\_secret) | The secret for the xsiam http endpoint | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log"></a> [cloudwatch\_log](#output\_cloudwatch\_log) | The cloudwatch log created for the firewall |
<!-- END_TF_DOCS -->