# Core Monitoring

Terraform module used to create monitoring topics and pagerduty subscriptions for core accounts.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pagerduty_core_alerts"></a> [pagerduty\_core\_alerts](#module\_pagerduty\_core\_alerts) | github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration | v1.0.0 |
| <a name="module_pagerduty_high_priority"></a> [pagerduty\_high\_priority](#module\_pagerduty\_high\_priority) | github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration | v1.0.0 |
| <a name="module_pagerduty_low_priority"></a> [pagerduty\_low\_priority](#module\_pagerduty\_low\_priority) | github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.high_priority_alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.low_priority_alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pagerduty_integration_keys"></a> [pagerduty\_integration\_keys](#input\_pagerduty\_integration\_keys) | Map of pagerduty integration keys | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->