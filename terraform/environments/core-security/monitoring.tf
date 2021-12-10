module "pagerduty_core_alerts" {
  source                     = "../../modules/pagerduty-integration"
  sns_topics                 = ["config", "securityhub-alarms", "cloudtrail"]
  pagerduty_integration_name = "core_alerts_cloudwatch"
}
