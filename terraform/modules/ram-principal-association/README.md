# Resource Access Manager Principal Association

Terraform module for creating principal associations required for RAM resource sharing.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.share-acm"></a> [aws.share-acm](#provider\_aws.share-acm) | ~> 6.0 |
| <a name="provider_aws.share-host"></a> [aws.share-host](#provider\_aws.share-host) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ram_principal_association.acm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_principal_association.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_share.acm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ram_resource_share) | data source |
| [aws_ram_resource_share.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ram_resource_share) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_pca"></a> [acm\_pca](#input\_acm\_pca) | ACM certificate manager | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | environment | `string` | n/a | yes |
| <a name="input_principal"></a> [principal](#input\_principal) | Principal to share with | `string` | n/a | yes |
| <a name="input_subnet_set"></a> [subnet\_set](#input\_subnet\_set) | Subnet set to attach to | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name for the VPC | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->