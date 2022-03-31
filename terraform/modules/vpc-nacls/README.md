# VPC NACL

Terraform module for creating subnet NACLs

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
| [aws_network_acl_rule.custom_nacl_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.open_endpoint_cidrs_for_data_subnets_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.open_endpoint_cidrs_for_data_subnets_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidrs_for_s3_endpoints"></a> [cidrs\_for\_s3\_endpoints](#input\_cidrs\_for\_s3\_endpoints) | cidrs\_for\_s3\_endpoints | `list(any)` | n/a | yes |
| <a name="input_nacl_config"></a> [nacl\_config](#input\_nacl\_config) | List of maps of NACLs configurations | `list(any)` | n/a | yes |
| <a name="input_nacl_refs"></a> [nacl\_refs](#input\_nacl\_refs) | Map of internal NACL references including arn, id, and name | `map(any)` | n/a | yes |
| <a name="input_tags_prefix"></a> [tags\_prefix](#input\_tags\_prefix) | Prefix for name tags | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->