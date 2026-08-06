locals {
  s3_replication_rules = {
    config = {
      source_bucket      = "modernisation-platform-logs-config"
      destination_bucket = "modernisation-platform-logs-config-replication"
    }
  }
}

# S3 publishes OperationsFailedReplication in the source bucket's Region.
resource "aws_cloudwatch_metric_alarm" "s3_replication_failures" {
  for_each = local.s3_replication_rules

  alarm_name        = "${each.value.source_bucket}-replication-failures"
  alarm_description = "S3 operations have failed replication from ${each.value.source_bucket} to ${each.value.destination_bucket}."

  namespace           = "AWS/S3"
  metric_name         = "OperationsFailedReplication"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    SourceBucket      = each.value.source_bucket
    DestinationBucket = each.value.destination_bucket
    RuleId            = "SourceToDestinationReplication"
  }

  alarm_actions = [aws_sns_topic.s3_replication_failures.arn]
  ok_actions    = [aws_sns_topic.s3_replication_failures.arn]

  tags = local.tags
}

# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "s3_replication_failures" {
  # checkov:skip=CKV_AWS_26:"encrypted topics do not work with PagerDuty subscriptions"
  name = "s3-replication-failures"
  tags = local.tags
}

data "aws_iam_policy_document" "s3_replication_failures" {
  statement {
    sid    = "AllowCloudWatchAlarms"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.s3_replication_failures.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"]
    }
  }
}

resource "aws_sns_topic_policy" "s3_replication_failures" {
  arn    = aws_sns_topic.s3_replication_failures.arn
  policy = data.aws_iam_policy_document.s3_replication_failures.json
}

module "pagerduty_s3_replication_failures" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0

  sns_topics                = [aws_sns_topic.s3_replication_failures.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]

  depends_on = [aws_sns_topic.s3_replication_failures]
}
