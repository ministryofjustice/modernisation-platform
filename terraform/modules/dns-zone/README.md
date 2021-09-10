# DNS Zone creation

Terraform module for creating core DNS zones

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.47.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.47.0 |
| <a name="provider_aws.core-network-services"></a> [aws.core-network-services](#provider\_aws.core-network-services) | >= 3.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.mod-ns-private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.mod-ns-public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | n/a | `map(any)` | n/a | yes |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | n/a | `string` | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | n/a | `any` | n/a | yes |
| <a name="input_modernisation_platform_account"></a> [modernisation\_platform\_account](#input\_modernisation\_platform\_account) | n/a | `any` | n/a | yes |
| <a name="input_private_dns_zone"></a> [private\_dns\_zone](#input\_private\_dns\_zone) | n/a | `any` | n/a | yes |
| <a name="input_public_dns_zone"></a> [public\_dns\_zone](#input\_public\_dns\_zone) | n/a | `any` | n/a | yes |
| <a name="input_tags_common"></a> [tags\_common](#input\_tags\_common) | MOJ required tags | `map(string)` | n/a | yes |
| <a name="input_tags_prefix"></a> [tags\_prefix](#input\_tags\_prefix) | prefix for name tags | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_zone_private"></a> [zone\_private](#output\_zone\_private) | n/a |
| <a name="output_zone_public"></a> [zone\_public](#output\_zone\_public) | n/a |

<!--- END_TF_DOCS --->

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
