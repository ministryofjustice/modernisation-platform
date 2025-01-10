# R53 Resolver DNS Firewall Resources - created on a per-VPC basis

# Rule group
resource "aws_route53_resolver_firewall_rule_group" "this" {
  name = "${var.tags_prefix}-r53-dns-firewall-rule-group"
  tags = var.tags_common
}

# Allowed domain list
resource "aws_route53_resolver_firewall_domain_list" "allow" {
  name    = "${var.tags_prefix}-allow-domain-list"
  domains = [for domain in var.allowed_domains : "${domain}."]
  tags    = var.tags_common
}

# Blocked domain list
resource "aws_route53_resolver_firewall_domain_list" "block" {
  name    = "${var.tags_prefix}-block-domain-list"
  domains = [for domain in var.blocked_domains : "${domain}."]
  tags    = var.tags_common
}

# Default rule to ALERT on AWS-managed bad domain lists - see https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-managed-domain-lists.html
# These rules will be set to ALERT initially and enabled in production - after a period of monitoring we will switch to BLOCK
data "external" "aws_managed_domain_lists" {
  program = ["bash", "${path.module}/fetch-aws-managed-domain-lists.sh"]
}
resource "aws_route53_resolver_firewall_rule" "default_alert" {
  for_each = data.external.aws_managed_domain_lists.result


  action                  = "ALERT"
  firewall_domain_list_id = each.value
  priority                = each.key == "AWSManagedDomainsAggregateThreatList" ? 2 : each.key == "AWSManagedDomainsMalwareDomainList" ? 3 : each.key == "AWSManagedDomainsBotnetCommandandControl" ? 4 : 5
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  name                    = "Alert_${each.key}"
  # block_response          = var.block_response # Leaving this commented out until we turn on blocking in a future PR
}

# Rule to allow domains in the allow list (takes top priority)
resource "aws_route53_resolver_firewall_rule" "allow" {
  action                  = "ALLOW"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.allow.id
  priority                = 1
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  name                    = "Allow_${var.tags_prefix}_domain_list"
}

# Rule to block domains in the block list (takes lowest priority)
resource "aws_route53_resolver_firewall_rule" "block" {
  action                  = "BLOCK"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.block.id
  priority                = 6
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.this.id
  name                    = "Block_${var.tags_prefix}_domain_list"
  block_response          = var.block_response # defaults to NXDOMAIN
}

# Association of the rule group with the VPC
resource "aws_route53_resolver_firewall_rule_group_association" "this" {
  firewall_rule_group_id = aws_route53_resolver_firewall_rule_group.this.id
  vpc_id                 = var.vpc_id
  priority               = var.association_priority
  name                   = "${var.tags_prefix}-association"
  tags                   = var.tags_common
}

# Configures DNS Firewall logging to CloudWatch 
resource "aws_route53_resolver_query_log_config" "dns_firewall_log_config" {
  name            = "${var.tags_prefix}-rqlc-cloudwatch"
  destination_arn = aws_cloudwatch_log_group.dns_firewall_log_group.arn
  tags            = var.tags_common
}

# Associate the DNS Firewall log config with the VPC
resource "aws_route53_resolver_query_log_config_association" "dns_firewall_log_config_association" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.dns_firewall_log_config.id
  resource_id                  = var.vpc_id
}

# Creates a CloudWatch log group for DNS Firewall logs (logs retained for 365 days)
resource "aws_cloudwatch_log_group" "dns_firewall_log_group" {
  name              = "/aws/route53resolver/dns_firewall/${var.tags_prefix}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.dns_firewall_kms_key.arn
  tags              = var.tags_common
}

# Creates a metric filter for DNS Firewall logs to count the number of domain matches that are blocked or alerted on
resource "aws_cloudwatch_log_metric_filter" "dns_firewall_metric_filter" {
  name           = "${var.tags_prefix}-DNSFirewallMatches"
  log_group_name = aws_cloudwatch_log_group.dns_firewall_log_group.name

  pattern = "{ ($.firewall_rule_action = \"BLOCK\" || $.firewall_rule_action = \"ALERT\") && $.vpc_id = \"${var.vpc_id}\" }"
  metric_transformation {
    name      = "${var.tags_prefix}-DNSFirewallMatches"
    namespace = "DNSFirewall"
    value     = "1"
  }
}

# Creates a CloudWatch alarm to alert on DNS Firewall matches and links to an SNS topic
resource "aws_cloudwatch_metric_alarm" "dns_firewall_alarm" {
  alarm_name          = "${var.tags_prefix}-DNSFirewallMatchesAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.dns_firewall_metric_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.dns_firewall_metric_filter.metric_transformation[0].namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = [aws_sns_topic.dns_firewall_sns_topic.arn]
  tags          = var.tags_common
}

# Creates an SNS topic for DNS Firewall matches
resource "aws_sns_topic" "dns_firewall_sns_topic" {
  name              = "${var.tags_prefix}-DNSFirewallMatchesTopic"
  kms_master_key_id = aws_kms_key.dns_firewall_kms_key.key_id
  tags              = var.tags_common
}

# Creates a KMS key for DNS Firewall SNS Topic encryption
resource "aws_kms_key" "dns_firewall_kms_key" {
  description         = "KMS key for DNS Firewall SNS Topic Encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.dns_firewall_kms_policy.json
  tags                = var.tags_common
}

resource "aws_kms_alias" "dns_firewall_kms_alias" {
  name_prefix   = "alias/${var.tags_prefix}-DNSFirewallSNSKey"
  target_key_id = aws_kms_key.dns_firewall_kms_key.key_id
}

# Policy for the KMS key to allow SNS/Cloudwatch services to use the key
data "aws_iam_policy_document" "dns_firewall_kms_policy" {
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

# Data source to get the current AWS account ID
data "aws_caller_identity" "current" {}

# Subscribes the SNS topic to PagerDuty
module "pagerduty_r53_dns_firewall" {
  depends_on                = [aws_sns_topic.dns_firewall_sns_topic]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.dns_firewall_sns_topic.name]
  pagerduty_integration_key = var.pagerduty_integration_key
}