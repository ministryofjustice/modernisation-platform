# SNS topics for high and low priority alarms

# tfsec:ignore:aws-sns-topic-encryption-use-cmk
resource "aws_sns_topic" "high_priority_alarms" {
  name              = "high_priority_alarms"
  kms_master_key_id = "alias/aws/sns"
}

# tfsec:ignore:aws-sns-topic-encryption-use-cmk
resource "aws_sns_topic" "low_priority_alarms" {
  name              = "low_priority_alarms"
  kms_master_key_id = "alias/aws/sns"
}

# subscribe to the sns topics the pagerduty service
module "pagerduty_high_priority" {
  depends_on = [
    aws_sns_topic.high_priority_alarms
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=v1.0.0"
  sns_topics                = [aws_sns_topic.high_priority_alarms.name]
  pagerduty_integration_key = var.pagerduty_integration_keys["high_priority_alarms"]
}

module "pagerduty_low_priority" {
  depends_on = [
    aws_sns_topic.low_priority_alarms
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=v1.0.0"
  sns_topics                = [aws_sns_topic.low_priority_alarms.name]
  pagerduty_integration_key = var.pagerduty_integration_keys["low_priority_alarms"]
}

module "pagerduty_core_alerts" {
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=v1.0.0"
  sns_topics                = ["config", "securityhub-alarms", "cloudtrail"]
  pagerduty_integration_key = var.pagerduty_integration_keys["core_alerts_cloudwatch"]
}
