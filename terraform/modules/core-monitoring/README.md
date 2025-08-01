# Core Monitoring

Terraform module used to create monitoring topics and PagerDuty subscriptions for core accounts.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pagerduty_core_alerts"></a> [pagerduty\_core\_alerts](#module\_pagerduty\_core\_alerts) | github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration | d88bd90d490268896670a898edfaba24bba2f8ab |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pagerduty_integration_keys"></a> [pagerduty\_integration\_keys](#input\_pagerduty\_integration\_keys) | Map of pagerduty integration keys | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
