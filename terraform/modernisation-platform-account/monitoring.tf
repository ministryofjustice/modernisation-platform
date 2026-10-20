module "pagerduty_core_alerts" {
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  sns_topics                = ["config", "securityhub-alarms", "cloudtrail"]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}

moved {
  from = module.core_monitoring.module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["cloudtrail"]
  to   = module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["cloudtrail"]
}

moved {
  from = module.core_monitoring.module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["config"]
  to   = module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["config"]
}

moved {
  from = module.core_monitoring.module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["securityhub-alarms"]
  to   = module.pagerduty_core_alerts.aws_sns_topic_subscription.pagerduty_subscription["securityhub-alarms"]
}