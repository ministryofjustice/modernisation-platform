# Usage

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.0  |

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 6.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                 | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_ecr_repository.ecr_repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)                            | resource    |
| [aws_ecr_repository_policy.ecr_repository_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource    |
| [aws_iam_policy_document.ecr_repo_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)        | data source |

## Inputs

| Name                                                                                                                                       | Description                                                                       | Type           | Default | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_app_name"></a> [app_name](#input_app_name)                                                                                  | base name for ecr repo                                                            | `string`       | n/a     |   yes    |
| <a name="input_enable_retrieval_policy_for_lambdas"></a> [enable_retrieval_policy_for_lambdas](#input_enable_retrieval_policy_for_lambdas) | If set then it will add ECR Image Retrieval Policy for the given Lambda functions | `list(string)` | `[]`    |    no    |
| <a name="input_pull_principals"></a> [pull_principals](#input_pull_principals)                                                             | AWS principals which require access to pull from the repository                   | `list(string)` | `[]`    |    no    |
| <a name="input_push_principals"></a> [push_principals](#input_push_principals)                                                             | AWS principals which require access to push to the repository                     | `list(string)` | `[]`    |    no    |
| <a name="input_tags_common"></a> [tags_common](#input_tags_common)                                                                         | MOJ required tags                                                                 | `map(string)`  | n/a     |   yes    |

## Outputs

| Name                                                                                         | Description   |
| -------------------------------------------------------------------------------------------- | ------------- |
| <a name="output_ecr_repository_name"></a> [ecr_repository_name](#output_ecr_repository_name) | ECR Repo Name |

<!-- END_TF_DOCS -->
