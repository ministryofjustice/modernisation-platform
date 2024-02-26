
# Data source to get the ARN of an existing SNS topic
data "aws_sns_topic" "existing_topic" {
  count         = local.account_data.account-type != "member-unrestricted" ? 1 : 0
  name = "backup_failure_topic"
}

# Create an email subscription to the existing SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  count         = local.account_data.account-type != "member-unrestricted" ? 1 : 0
  topic_arn =  data.aws_sns_topic.existing_topic[0].arn
  protocol  = "email"
  endpoint  = "modernisation-platform@digital.justice.gov.uk"
}

# Link the sns topics to the pagerduty service
module "pagerduty_core_alerts" {
  count         = (local.account_data.account-type != "member-unrestricted") ? 1 : 0
  depends_on = [
    data.aws_sns_topic.existing_topic
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [data.aws_sns_topic.existing_topic[count.index]]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}

resource "aws_cloudwatch_metric_alarm" "aws_backup_has_errors" {
  count         = local.account_data.account-type != "member-unrestricted" ? 1 : 0
  alarm_name        = "aws-backup-failed"
  alarm_description = "AWS Backup, everything has failed. Please check logs"
  alarm_actions = [data.aws_sns_topic.existing_topic[0].arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Backup"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "aws-backup-failure"
  }

}

data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
 }

# Get the map of pagerduty integration keys
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-platform
  name     = "pagerduty_integration_keys"
}

locals {
    pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)
}