# Firehose

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

No modules.

## Resources

| Name                                                                                                                                                                                               | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_log_group.delivery_errors_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                             | resource |
| [aws_cloudwatch_log_stream.delivery_errors_log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream)                                          | resource |
| [aws_cloudwatch_log_subscription_filter.subscription_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter)                       | resource |
| [aws_iam_policy.error_log_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                          | resource |
| [aws_iam_policy.put_record_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                         | resource |
| [aws_iam_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                                 | resource |
| [aws_iam_role.delivery_stream_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                          | resource |
| [aws_iam_role.put_record_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                               | resource |
| [aws_iam_role_policy.delivery_stream_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                                     | resource |
| [aws_iam_role_policy_attachment.error_log_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                 | resource |
| [aws_iam_role_policy_attachment.put_record_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                              | resource |
| [aws_iam_role_policy_attachment.s3_role_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                        | resource |
| [aws_kinesis_firehose_delivery_stream.delivery_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream)                               | resource |
| [aws_s3_bucket.firehose_error_logging_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                               | resource |
| [aws_s3_bucket_lifecycle_configuration.bucket_lifecycle_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                     | resource |
| [aws_s3_bucket_public_access_block.bucket_block_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                 | resource |
| [aws_s3_bucket_server_side_encryption_configuration.bucket_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource |
| [random_string.firehose_rnd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                                                | resource |

## Inputs

| Name                                                                              | Description                                                                                                                   | Type       | Default | Required |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ---------- | ------- | :------: |
| <a name="input_common_attribute"></a> [common_attribute](#input_common_attribute) | The value of the common_attributes property which should be the name of the aws account or the account name & live / non-live | `string`   | n/a     |   yes    |
| <a name="input_log_group_name"></a> [log_group_name](#input_log_group_name)       | The name of the log group that the subscription will be added to                                                              | `string`   | n/a     |   yes    |
| <a name="input_resource_prefix"></a> [resource_prefix](#input_resource_prefix)    | The prefix to be used for the resource names - used for easy identification                                                   | `string`   | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                     | A map of keys and values used to create resource metadata tags                                                                | `map(any)` | n/a     |   yes    |
| <a name="input_xsiam_endpoint"></a> [xsiam_endpoint](#input_xsiam_endpoint)       | The http endpoint URL for the transfer of log data via firehose                                                               | `string`   | n/a     |   yes    |
| <a name="input_xsiam_secret"></a> [xsiam_secret](#input_xsiam_secret)             | The secret for the xsiam http endpoint                                                                                        | `string`   | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
