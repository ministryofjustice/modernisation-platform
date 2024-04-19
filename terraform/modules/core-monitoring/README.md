# Core Monitoring

Terraform module used to create monitoring topics and PagerDuty subscriptions for core accounts.

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 5.0  |

## Providers

No providers.

## Modules

| Name                                                                                               | Source                                                                              | Version                                  |
| -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------- |
| <a name="module_pagerduty_core_alerts"></a> [pagerduty_core_alerts](#module_pagerduty_core_alerts) | github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration | 0179859e6fafc567843cd55c0b05d325d5012dc4 |

## Resources

No resources.

## Inputs

| Name                                                                                                            | Description                       | Type       | Default | Required |
| --------------------------------------------------------------------------------------------------------------- | --------------------------------- | ---------- | ------- | :------: |
| <a name="input_pagerduty_integration_keys"></a> [pagerduty_integration_keys](#input_pagerduty_integration_keys) | Map of pagerduty integration keys | `map(any)` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
