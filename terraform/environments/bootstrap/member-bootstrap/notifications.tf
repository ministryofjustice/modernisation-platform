locals {
  is_production       = can(regex("production|default", terraform.workspace))
  existing_topic_name = try(data.aws_sns_topic.existing_topic[0].name, null)
  backup_topic_name   = try(data.aws_sns_topic.backup_vault_failure_topic[0].name, null)
  high_priority_topic = try(data.aws_sns_topic.high_priority_topic[0].name, null)
}

data "aws_region" "current" {}

# Data source to get the ARN of an existing SNS topic
data "aws_sns_topic" "existing_topic" {
  count = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
  name  = "backup_failure_topic"

}

data "aws_sns_topic" "backup_vault_failure_topic" {
  count = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
  name  = "backup_vault_failure_topic"

}

# Data source to get the ARN of the high priority SNS topic
data "aws_sns_topic" "high_priority_topic" {
  name  = "high-priority-alarms"
}

# Link the sns topics to the pagerduty service
module "pagerduty_core_alerts" {
  count = (local.account_data.account-type != "member-unrestricted") ? 1 : 0
  depends_on = [
    data.aws_sns_topic.existing_topic, data.aws_sns_topic.backup_vault_failure_topic
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = compact([local.existing_topic_name, local.backup_topic_name])
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}

module "pagerduty_high_priority_alarms" {
  count = (local.account_data.account-type != "member-unrestricted") ? 1 : 0
  depends_on = [
    data.aws_sns_topic.high_priority_topic
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = compact([local.high_priority_topic.name])
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_high_priority_cloudwatch"]
}

# Cloudwatch metric alarm required for errors
resource "aws_cloudwatch_metric_alarm" "aws_backup_has_errors" {
  count             = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
  alarm_name        = "aws-backup-failed"
  alarm_description = "AWS Backup, everything has failed. Please check logs"
  alarm_actions     = [data.aws_sns_topic.existing_topic[0].arn]

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

data "aws_cloudwatch_log_group" "cloudtrail" {
  name = "cloudtrail"
}
resource "aws_cloudwatch_log_metric_filter" "backup_vault_lock_changes" {
  count          = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
  name           = "BackupVaultLockChanges"
  pattern        = "{($.eventSource = \"backup.amazonaws.com\") && (($.eventName = \"PutBackupVaultLockConfiguration\") || ($.eventName = \"DeleteBackupVaultLockConfiguration\") || ($.eventName = \"ChangeBackupVaultLockConfiguration\") || ($.eventName = \"PutBackupVaultAccessPolicy\"))}"
  log_group_name = data.aws_cloudwatch_log_group.cloudtrail.name

  metric_transformation {
    name      = "CallCount"
    namespace = "CustomMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "backup_vault_config_alarm" {
  count             = (local.is_production && data.aws_region.current.name == "eu-west-2") ? 1 : 0
  alarm_name        = "backup-vault-config-change"
  alarm_description = "Alarm when there are changes to Backup Vault configurations. Please check logs"
  alarm_actions     = [data.aws_sns_topic.backup_vault_failure_topic[0].arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CallCount"
  namespace           = "CustomMetrics"
  period              = "10"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"


  depends_on = [aws_cloudwatch_log_metric_filter.backup_vault_lock_changes]
}

# Keys for pagerduty
data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-secrets-read
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}

# Get the map of pagerduty integration keys
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-secrets-read
  name     = "pagerduty_integration_keys"
}

# Keys for pagerduty
locals {
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)
}

# Subscribe SNS topics in member accounts to pagerduty for core monitoring
module "core_monitoring" {
  source                     = "../../../modules/core-monitoring"
  depends_on                 = [data.aws_sns_topic.existing_topic]
  pagerduty_integration_keys = local.pagerduty_integration_keys
}
