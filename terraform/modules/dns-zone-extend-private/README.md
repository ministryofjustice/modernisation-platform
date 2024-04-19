# DNS Zone Extend Private

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0  |

## Providers

| Name                                                                                                               | Version |
| ------------------------------------------------------------------------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                                                                   | ~> 5.0  |
| <a name="provider_aws.core-network-services"></a> [aws.core-network-services](#provider_aws.core-network-services) | ~> 5.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                 | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_route53_vpc_association_authorization.private_zone_vpc_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_vpc_association_authorization) | resource    |
| [aws_route53_zone_association.private_zone_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association)                              | resource    |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)                                                              | data source |

## Inputs

| Name                                                         | Description                                               | Type       | Default | Required |
| ------------------------------------------------------------ | --------------------------------------------------------- | ---------- | ------- | :------: |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)          | ID of the VPC to be associated with the private DNS zone. | `string`   | n/a     |   yes    |
| <a name="input_zone_name"></a> [zone_name](#input_zone_name) | Name of private DNS zone passed into module for lookup.   | `map(any)` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
