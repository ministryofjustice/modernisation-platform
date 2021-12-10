# subscribe to SNS topics for pagerduty
data "aws_sns_topic" "alarm_topics" {
  for_each = toset(var.sns_topics)
  name     = each.key
}

resource "aws_sns_topic_subscription" "pagerduty_subscription" {
  for_each  = data.aws_sns_topic.alarm_topics
  topic_arn = each.value.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/${var.pagerduty_integration_key}/enqueue"
}
