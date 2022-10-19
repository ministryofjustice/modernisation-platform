# Usage

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
| [aws_ecr_repository.ecr_repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.ecr_repository_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.ecr_repo_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | base name for ecr repo | `string` | n/a | yes |
| <a name="input_enable_retrieval_policy_for_lambdas"></a> [enable\_retrieval\_policy\_for\_lambdas](#input\_enable\_retrieval\_policy\_for\_lambdas) | If set then it will add ECR Image Retrieval Policy for the given Lambda functions | `list(string)` | `[]` | no |
| <a name="input_pull_principals"></a> [pull\_principals](#input\_pull\_principals) | AWS principals which require access to pull from the repository | `list(string)` | `[]` | no |
| <a name="input_push_principals"></a> [push\_principals](#input\_push\_principals) | AWS principals which require access to push to the repository | `list(string)` | `[]` | no |
| <a name="input_tags_common"></a> [tags\_common](#input\_tags\_common) | MOJ required tags | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_name"></a> [ecr\_repository\_name](#output\_ecr\_repository\_name) | ECR Repo Name |
<!-- END_TF_DOCS -->