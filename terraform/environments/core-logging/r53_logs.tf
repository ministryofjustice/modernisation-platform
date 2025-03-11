locals {
  resolver_query_log_configs = {
    s3         = aws_route53_resolver_query_log_config.s3.arn
    cloudwatch = aws_route53_resolver_query_log_config.cloudwatch.arn
  }
}

resource "aws_route53_resolver_query_log_config" "s3" {
  name            = format("%s-rlq-s3", local.application_name)
  destination_arn = aws_s3_bucket.logging["r53-resolver-logs"].arn

}

resource "aws_route53_resolver_query_log_config" "cloudwatch" {
  name            = format("%s-rlq-cloudwatch", local.application_name)
  destination_arn = aws_cloudwatch_log_group.r53_resolver_logs.arn

}

resource "aws_ram_resource_share" "resolver_query_share" {
  allow_external_principals = false
  name                      = format("%s-resolver-log-query-share", local.application_name)

}

resource "aws_ram_resource_association" "resolver_query_share" {
  for_each           = local.resolver_query_log_configs
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.resolver_query_share.id
}

resource "aws_ram_principal_association" "resolver_query_share" {
  principal          = replace("${data.aws_organizations_organization.root_account.arn}/${local.environment_management.modernisation_platform_organisation_unit_id}", "organization/", "ou/")
  resource_share_arn = aws_ram_resource_share.resolver_query_share.arn
}

resource "aws_cloudwatch_log_group" "r53_resolver_logs" {
  kms_key_id        = aws_kms_key.r53_resolver_logs.arn
  name_prefix       = "r53-resolver-logs"
  retention_in_days = 365

}

resource "aws_kms_key" "r53_resolver_logs" {
  description         = "KMS key used to encrypt R53 Resolver Logs CloudWatch log group"
  enable_key_rotation = true
  multi_region        = true
  policy              = data.aws_iam_policy_document.r53_resolver_logs_kms.json

}

data "aws_iam_policy_document" "r53_resolver_logs_kms" {
  #checkov:skip=CKV_AWS_109:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_111:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_356:"Policy is directly related to the resource"
  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Allow AWS Log service to use key"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com"
      ]
    }
  }
}

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

}

resource "aws_sns_topic" "r53_dns_firewall" {
  name              = "r53-dns-firewall-sns-topic"
  kms_master_key_id = aws_kms_key.r53_dns_firewall.key_id

}

resource "aws_kms_key" "r53_dns_firewall" {
  description         = "KMS key for DNS Firewall SNS Topic Encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.r53_dns_firewall_kms_policy.json

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
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.r53_dns_firewall.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}
