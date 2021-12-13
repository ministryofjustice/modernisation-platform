module "pagerduty_core_alerts" {
  source                    = "../../modules/pagerduty-integration"
  sns_topics                = ["config", "securityhub-alarms", "cloudtrail"]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}
