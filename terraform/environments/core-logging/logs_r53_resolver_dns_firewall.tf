resource "aws_cloudwatch_log_metric_filter" "r53_dns_firewall_metric_filter" {
  name           = "r53-dns-firewall-matches"
  log_group_name = aws_cloudwatch_log_group.r53_resolver_logs.name

  pattern = "{ ($.firewall_rule_action = \"BLOCK\" || $.firewall_rule_action = \"ALERT\") }"
  metric_transformation {
    name      = "r53-dns-firewall-matches"
    namespace = "R53DNSFirewall"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "r53_dns_firewall_alarm" {
  alarm_name          = "r53-dns-firewall-matches"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.r53_dns_firewall_metric_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.r53_dns_firewall_metric_filter.metric_transformation[0].namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_actions       = [aws_sns_topic.r53_dns_firewall.arn]
  tags                = local.tags
}

resource "aws_sns_topic" "r53_dns_firewall" {
  name              = "r53-dns-firewall-sns-topic"
  kms_master_key_id = aws_kms_key.r53_dns_firewall.key_id
  tags              = local.tags
}

resource "aws_kms_key" "r53_dns_firewall" {
  description         = "KMS key for DNS Firewall SNS Topic Encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.r53_dns_firewall_kms_policy.json
  tags                = merge(local.tags, { Name = "${local.application_name}-r53-kms" })
}

resource "aws_kms_alias" "r53_dns_firewall" {
  name_prefix   = "alias/r53-dns-firewall-sns-encryption"
  target_key_id = aws_kms_key.r53_dns_firewall.key_id
}

data "aws_iam_policy_document" "r53_dns_firewall_kms_policy" {
  # checkov:skip=CKV_AWS_111: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_109: "policy is directly related to the resource"
  # checkov:skip=CKV_AWS_356: "policy is directly related to the resource"
  statement {
    sid    = "Allow SNS/Cloudwatch services to use the KMS key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      "*"
    ]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com", "cloudwatch.amazonaws.com", "logs.amazonaws.com"]
    }
  }

  statement {
    sid    = "Allow account to manage key"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
module "pagerduty_r53_dns_firewall" {
  depends_on                = [aws_sns_topic.r53_dns_firewall]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  sns_topics                = [aws_sns_topic.r53_dns_firewall.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}
