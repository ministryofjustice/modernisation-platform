locals {
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)
  pagerduty_integration_key  = local.pagerduty_integration_keys[var.pagerduty_integration_name]
}

# subscribe to SNS topics for pagerduty
data "aws_sns_topic" "alarm_topics" {
  for_each = toset(var.sns_topics)
  name     = each.key
}

data "aws_secretsmanager_secret" "pagerduty_integration_keys" {
  name = "pagerduty_integration_keys"
}

data "aws_secretsmanager_secret_version" "pagerduty_integration_keys" {
  secret_id = data.aws_secretsmanager_secret.pagerduty_integration_keys.id
}

resource "aws_sns_topic_subscription" "pagerduty_subscription" {
  for_each  = data.aws_sns_topic.alarm_topics
  topic_arn = each.value.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/${local.pagerduty_integration_key}/enqueue"
}
