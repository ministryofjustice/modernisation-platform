module "core_monitoring" {
  source                     = "../../modules/core-monitoring"
  pagerduty_integration_keys = local.pagerduty_integration_keys
}

