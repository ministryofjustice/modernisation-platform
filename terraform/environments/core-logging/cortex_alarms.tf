# This adds a cloudwatch alarm for each of the sqs queues that monitor for a build up of messages.
# We will output this to modernisation-platform-low-priority-alarms as well as the xsiam-alerts channel id that has been provided by SecOps.

locals {

  cortex_topic_names = [
    { name = "modplatform", channel_id = "C02PFCG8M1R" }, #modernisation-platform-low-priority-alarms
    { name = "secops", channel_id = "C082F6H8A2Z" }       #xsiam-alerts
  ]

  max_queue_message_age = 3600 # Value in seconds. Suggested default value is 3600 seconds (1 hour)
}

# This creates one cloudwatch alarm for each of the cortex logging buckets.

resource "aws_cloudwatch_metric_alarm" "sqs_cortex_age_of_oldest_message" {
  for_each            = local.cortex_logging_buckets
  alarm_name          = "${each.key}-ApproximateAgeOfOldestMessage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = local.max_queue_message_age # This value is in seconds
  alarm_description   = "Alarm for ApproximateAgeOfOldestMessage over ${local.max_queue_message_age} seconds for SQS queue ${each.key}"
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = aws_sqs_queue.logging[each.key].name
  }
  alarm_actions = [for topic in local.cortex_topic_names : aws_sns_topic.cortex_sqs_sns_topic[topic.name].arn]
  tags          = local.tags
}

# KMS Key & Policy for SNS Encryption

resource "aws_kms_key" "sns_kms_key" {
  description         = "KMS key for SQS SNS topic encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.sns_kms_policy.json
}

resource "aws_kms_alias" "sns_kms_alias" {
  name          = "alias/sqs-sns-kms-key"
  target_key_id = aws_kms_key.sns_kms_key.id
}

# Static code analysis ignores:
# - CKV_AWS_109 and CKV_AWS_111: Ignore warnings regarding resource = ["*"]. See https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
#   Specifically: "In a key policy, the value of the Resource element is "*", which means "this KMS key." The asterisk ("*") identifies the KMS key to which the key policy is attached."
data "aws_iam_policy_document" "sns_kms_policy" {
  # checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource - see note above"
  # checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource - see note above"
  # checkov:skip=CKV_AWS_356: "Key policy requires asterisk resource - see note above"
  statement {
    sid    = "Allow management access of the key to the core-logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Allow SNS service to use the key"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# IAM Policies for SNS Encryption

## Here we use a common data statement for the two sns topic policies.

resource "aws_sns_topic_policy" "sqs_sns_topic_policy" {
  for_each = { for topic in local.cortex_topic_names : topic.name => topic }
  arn      = aws_sns_topic.cortex_sqs_sns_topic[each.key].arn
  policy   = data.aws_iam_policy_document.sqs_sns_topic_policy[each.key].json
}

data "aws_iam_policy_document" "sqs_sns_topic_policy" {
  for_each  = { for topic in local.cortex_topic_names : topic.name => topic }
  policy_id = "${each.value.name}-sqs-sns-topic-policy"
  statement {
    sid    = "Allow topic owner to manage sns topic"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:DeleteTopic",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:Receive",
      "sns:AddPermission",
      "sns:Subscribe"
    ]
    resources = [aws_sns_topic.cortex_sqs_sns_topic[each.key].arn]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}

# Slack Chatbot Integration

resource "aws_sns_topic" "cortex_sqs_sns_topic" {
  for_each          = { for topic in local.cortex_topic_names : topic.name => topic }
  name              = "${each.value.name}-sqs-sns-topic"
  kms_master_key_id = aws_kms_key.sns_kms_key.id
  tags              = local.tags
}

module "mp-sqs-sns-chatbot" {
  for_each         = { for topic in local.cortex_topic_names : topic.name => topic }
  source           = "github.com/ministryofjustice/modernisation-platform-terraform-aws-chatbot?ref=73280f80ce8a4557cec3a76ee56eb913452ca9aa" // v2.0.0
  slack_channel_id = each.value.channel_id
  sns_topic_arns   = [aws_sns_topic.cortex_sqs_sns_topic[each.key].arn]
  tags             = local.tags
  application_name = "${each.value.name}-sqs-alarm-chatbot"
}
