
resource "aws_backup_vault" "default" {
  #checkov:skip=CKV_AWS_166: "Ensure Backup Vault is encrypted at rest using KMS CMK - Tricky to implement, hence using AWS managed KMS key"

  name = var.aws_backup_vault_name
  tags = var.tags
}

# Backup vault lock
resource "aws_backup_vault_lock_configuration" "default" {
  backup_vault_name  = aws_backup_vault.default.name
  min_retention_days = 30
  max_retention_days = 60
}

# SNS topic
# trivy:ignore:avd-aws-0136
resource "aws_sns_topic" "backup_vault_topic" {
  kms_master_key_id = var.sns_backup_topic_key
  name              = var.backup_vault_lock_sns_topic_name
  tags = merge(var.tags, {
    Description = "This backup topic is so the MP team can subscribe to backup vault lock being turned off and member accounts can create their own subscriptions"
  })
}

resource "aws_cloudwatch_event_rule" "backup_vault_deleted_rule" {
  name          = "backup-vault-deleted-rule"
  event_pattern = <<EOF
{
  "source": ["aws.backup"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["backup.amazonaws.com"],
    "eventName": ["DeleteBackupVault"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "backup_vault_deleted_target" {
  rule = aws_cloudwatch_event_rule.backup_vault_deleted_rule.name
  arn  = aws_sns_topic.backup_vault_topic.arn
}


## Pager duty integration

# Get the map of pagerduty integration keys from the modernisation platform account
data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  provider = aws.modernisation-platform
  name     = "pagerduty_integration_keys"
}
data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  provider  = aws.modernisation-platform
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}

# Add a local to get the keys
locals {
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)
}

# link the sns topic to the service
module "pagerduty_core_alerts" {
  depends_on = [
    aws_sns_topic.backup_vault_topic
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=v2.0.0"
  sns_topics                = [aws_sns_topic.backup_vault_topic.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]

}





variable "backup_vault_lock_sns_topic_name" {
  default = "backup_vault_failure_topic"
  type    = string
}


variable "aws_backup_vault_name" {
  default = "everything"
  type    = string
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map(any)
}

variable "sns_backup_topic_key" {
  type        = string
  default     = "alias/aws/sns"
  description = "KMS key used to encrypt backup failure SNS topic"
}

