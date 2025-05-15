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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Pilot To Implement CloudWatch Anomaly Detection For VPC Flow Logs
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

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
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport=22,protocol=6,packets,bytes,start,end,action,logstatus]"

  metric_transformation {
    name      = "SSHConnectionAttempts"
    namespace = "VPCFlowMetrics"
    value     = "1"
  }
}

# Cloudwatch metric alarms for above filters

resource "aws_cloudwatch_metric_alarm" "accepted_traffic_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "AcceptedTrafficAlarm-${each.key}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "ad1"
  alarm_description   = "Anomaly detection alarm for accepted traffic in VPC '${each.key}'. A sudden spike or drop may indicate a network issue, service outage, or DDoS attempt."
  treat_missing_data  = "notBreaching"

  metric_query {
    id = "m1"
    metric {
      metric_name = "AcceptedTrafficCount"
      namespace   = "VPCFlowLogs"
      period      = 300
      stat        = "Sum"
    }
    return_data = false
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "AnomalyDetectionBand"
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "rejected_connections_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "RejectedConnectionsAlarm-${each.key}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "ad1"
  alarm_description   = "Anomaly detection alarm for rejected connections in VPC '${each.key}'. May indicate unauthorized access attempts, port scanning, or misconfigured security groups."
  treat_missing_data  = "notBreaching"

  metric_query {
    id = "m1"
    metric {
      metric_name = "RejectedConnections"
      namespace   = "VPCFlowMetrics"
      period      = 300
      stat        = "Sum"
    }
    return_data = false
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "AnomalyDetectionBand"
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ssh_connection_attempts_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "SSHConnectionAttemptsAlarm-${each.key}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "ad1"
  alarm_description   = "Anomaly detection alarm for SSH connection attempts (port 22) in VPC '${each.key}'. Indicates possible brute-force login attempts or unauthorized probing."
  treat_missing_data  = "notBreaching"

  metric_query {
    id = "m1"
    metric {
      metric_name = "SSHConnectionAttempts"
      namespace   = "VPCFlowMetrics"
      period      = 300
      stat        = "Sum"
    }
    return_data = false
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "AnomalyDetectionBand"
    return_data = true
  }
}