# DNS Zone creation

Terraform module for creating core DNS zones

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.0  |

## Providers

| Name                                                                                                               | Version |
| ------------------------------------------------------------------------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                                                                   | ~> 6.0  |
| <a name="provider_aws.aws-us-east-1"></a> [aws.aws-us-east-1](#provider_aws.aws-us-east-1)                         | ~> 6.0  |
| <a name="provider_aws.core-network-services"></a> [aws.core-network-services](#provider_aws.core-network-services) | ~> 6.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                              | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_metric_alarm.ddos_attack_public_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_route53_record.mod-ns-private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                   | resource |
| [aws_route53_record.mod-ns-public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                    | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)                                              | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)                                               | resource |
| [aws_shield_protection.public_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection)                         | resource |

## Inputs

| Name                                                                                                                        | Description          | Type          | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------- | -------------------- | ------------- | ------- | :------: |
| <a name="input_accounts"></a> [accounts](#input_accounts)                                                                   | n/a                  | `map(any)`    | n/a     |   yes    |
| <a name="input_dns_zone"></a> [dns_zone](#input_dns_zone)                                                                   | n/a                  | `string`      | n/a     |   yes    |
| <a name="input_environments"></a> [environments](#input_environments)                                                       | n/a                  | `any`         | n/a     |   yes    |
| <a name="input_modernisation_platform_account"></a> [modernisation_platform_account](#input_modernisation_platform_account) | n/a                  | `string`      | n/a     |   yes    |
| <a name="input_monitoring_sns_topic"></a> [monitoring_sns_topic](#input_monitoring_sns_topic)                               | n/a                  | `string`      | n/a     |   yes    |
| <a name="input_private_dns_zone"></a> [private_dns_zone](#input_private_dns_zone)                                           | n/a                  | `any`         | n/a     |   yes    |
| <a name="input_public_dns_zone"></a> [public_dns_zone](#input_public_dns_zone)                                              | n/a                  | `any`         | n/a     |   yes    |
| <a name="input_tags_common"></a> [tags_common](#input_tags_common)                                                          | MOJ required tags    | `map(string)` | n/a     |   yes    |
| <a name="input_tags_prefix"></a> [tags_prefix](#input_tags_prefix)                                                          | prefix for name tags | `string`      | n/a     |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                         | n/a                  | `string`      | n/a     |   yes    |

## Outputs

| Name                                                                    | Description |
| ----------------------------------------------------------------------- | ----------- |
| <a name="output_zone_private"></a> [zone_private](#output_zone_private) | n/a         |
| <a name="output_zone_public"></a> [zone_public](#output_zone_public)    | n/a         |

<!-- END_TF_DOCS -->
