resource "aws_cloudwatch_metric_alarm" "terraform_state_replication_failures" {
  alarm_name        = "modernisation-platform-terraform-state-replication-failures"
  alarm_description = "S3 operations have failed replication from modernisation-platform-terraform-state to modernisation-platform-terraform-state-replication."

  namespace           = "AWS/S3"
  metric_name         = "OperationsFailedReplication"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "ignore"

  dimensions = {
    SourceBucket      = "modernisation-platform-terraform-state"
    DestinationBucket = "modernisation-platform-terraform-state-replication"
    RuleId            = "SourceToDestinationReplication"
  }

  alarm_actions = [aws_sns_topic.terraform_state_replication_failures.arn]
  ok_actions    = [aws_sns_topic.terraform_state_replication_failures.arn]

  tags = local.tags
}

# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "terraform_state_replication_failures" {
  # checkov:skip=CKV_AWS_26:"Encrypted topics do not work with PagerDuty subscriptions"
  name = "terraform-state-replication-failures"
  tags = local.tags
}

data "aws_iam_policy_document" "terraform_state_replication_failures" {
  statement {
    sid    = "AllowCloudWatchAlarms"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.terraform_state_replication_failures.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:modernisation-platform-terraform-state-replication-failures"]
    }
  }
}

resource "aws_sns_topic_policy" "terraform_state_replication_failures" {
  arn    = aws_sns_topic.terraform_state_replication_failures.arn
  policy = data.aws_iam_policy_document.terraform_state_replication_failures.json
}

module "pagerduty_terraform_state_replication_failures" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0

  sns_topics                = [aws_sns_topic.terraform_state_replication_failures.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_high_priority_cloudwatch"]

  depends_on = [aws_sns_topic.terraform_state_replication_failures]
}
