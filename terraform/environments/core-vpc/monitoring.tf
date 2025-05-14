# Alarms for core monitoring - cloudtrail, security hub, config
module "core_monitoring" {
  source                     = "../../modules/core-monitoring"
  pagerduty_integration_keys = local.pagerduty_integration_keys
}

# SNS topic for Route53 Hosted Zone DDoS monitoring
# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "route53_monitoring" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  provider = aws.aws-us-east-1
  name     = "route53_monitoring"

  tags = local.tags
}

# subscribe to the sns topic to the pagerduty service
module "pagerduty_route53" {
  providers = {
    aws = aws.aws-us-east-1
  }
  depends_on = [
    aws_sns_topic.route53_monitoring
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.route53_monitoring.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["ddos_cloudwatch"]
}


# Pilot to Implement CloudWatch Anomaly Detection for VPC Flow Logs

locals {
  laa_vpc_keys = [
    "laa-production",
    "laa-preproduction",
    "laa-test",
    "laa-development",
    "laa-sandbox"
  ]

  laa_vpc_existing = { for k, v in module.vpc : k => v if contains(local.laa_vpc_keys, k) }
}

# Filters for vpc flow logs
resource "aws_cloudwatch_log_metric_filter" "accepted_traffic" {
  for_each       = local.laa_vpc_existing
  name           = "AcceptedTrafficCount-${each.key}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=ACCEPT,logstatus]"

  metric_transformation {
    name      = "AcceptedTrafficCount"
    namespace = "VPCFlowLogs"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "denied_traffic" {
  for_each       = local.laa_vpc_existing
  name           = "DeniedTrafficCount-${each.key}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=REJECT,logstatus]"

  metric_transformation {
    name      = "DeniedTrafficCount"
    namespace = "VPCFlowLogs"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "bytes_transferred" {
  for_each       = local.laa_vpc_existing
  name           = "BytesTransferred-${each.key}"
  log_group_name = each.value.vpc_flow_log
  pattern        = ""

  metric_transformation {
    name      = "BytesTransferred"
    namespace = "VPCFlowLogs"
    value     = "1"
    unit      = "Bytes"
  }
}

resource "aws_cloudwatch_log_metric_filter" "high_volume_traffic" {
  for_each       = local.laa_vpc_existing
  name           = "VPCFlowLogs-HighVolumeTraffic-${each.key}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes, ...]"

  metric_transformation {
    name          = "HighVolumeTraffic"
    namespace     = "VPCFlowMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "rejected_connections" {
  for_each       = local.laa_vpc_existing
  name           = "VPCFlowLogs-RejectedConnections-${each.key}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=REJECT,logstatus]"

  metric_transformation {
    name          = "RejectedConnections"
    namespace     = "VPCFlowMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "ssh_connection_attempts" {
  for_each       = local.laa_vpc_existing
  name           = "VPCFlowLogs-SSHConnectionAttempts-${each.key}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport=22,protocol=6, ...]"

  metric_transformation {
    name      = "SSHConnectionAttempts"
    namespace = "VPCFlowMetrics"
    value     = "1"
  }
}

# Cloudwatch metric alarm for above filters

resource "aws_cloudwatch_metric_alarm" "accepted_traffic_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "AcceptedTrafficAlarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.accepted_traffic[each.key].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.accepted_traffic[each.key].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if there is any accepted traffic in the VPC ${each.key}"
}

resource "aws_cloudwatch_metric_alarm" "denied_traffic_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "DeniedTrafficAlarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.denied_traffic[each.key].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.denied_traffic[each.key].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if there is any denied traffic in the VPC ${each.key}"
}

resource "aws_cloudwatch_metric_alarm" "bytes_transferred_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "BytesTransferredAlarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.bytes_transferred[each.key].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.bytes_transferred[each.key].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if there is any bytes transferred in the VPC ${each.key}"
}

resource "aws_cloudwatch_metric_alarm" "high_volume_traffic_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "HighVolumeTrafficAlarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.high_volume_traffic[each.key].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.high_volume_traffic[each.key].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if there is any high volume traffic in the VPC ${each.key}"
}

resource "aws_cloudwatch_metric_alarm" "rejected_connections_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "RejectedConnectionsAlarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.rejected_connections[each.key].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.rejected_connections[each.key].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if there are any rejected connections in the VPC ${each.key}"
}

resource "aws_cloudwatch_metric_alarm" "ssh_connection_attempts_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "SSHConnectionAttemptsAlarm-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.ssh_connection_attempts[each.key].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.ssh_connection_attempts[each.key].metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if there are any SSH connection attempts in the VPC ${each.key}"
}
