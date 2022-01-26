# KMS Keys

Terraform module used to create and secure standard keys for Ministry of Justice business units.

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

## Modules

No modules.

## Resources

| Name                                                                                                                               | Type |
|------------------------------------------------------------------------------------------------------------------------------------|------|
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                 | resource |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                             | resource |
| [aws_iam_policy_document.json](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | resource |

## Inputs


| Name                                                                                                          | Description | Type           | Default | Required |
|---------------------------------------------------------------------------------------------------------------|-------------|----------------|---------|:--------:|
| <a name="business_unit"></a> [pagerduty\_integration\_key](#input\_business\_unit)                            | n/a | `string`       | n/a | yes |
| <a name="business_unit_account_ids"></a> [business\_unit\_account\_ids](#input\_business\_unit\_account\_ids) | n/a | `list(string)` | n/a | yes |

## Outputs

No outputs.

<!--- END_TF_DOCS --->

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
