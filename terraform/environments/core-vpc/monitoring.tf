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
resource "aws_cloudwatch_log_metric_filter" "accepted_traffic" {
  name           = "AcceptedTrafficCount"
  log_group_name = module.vpc[local.vpc_key].vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=ACCEPT,logstatus]"

  metric_transformation {
    name      = "AcceptedTrafficCount"
    namespace = "VPCFlowLogs"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "denied_traffic" {
  name           = "DeniedTrafficCount"
  log_group_name = module.vpc[local.vpc_key].vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=REJECT,logstatus]"

  metric_transformation {
    name      = "DeniedTrafficCount"
    namespace = "VPCFlowLogs"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "bytes_transferred" {
  name           = "BytesTransferred"
  log_group_name = module.vpc[local.vpc_key].vpc_flow_log
  pattern        = ""

  metric_transformation {
    name      = "BytesTransferred"
    namespace = "VPCFlowLogs"
    value     = "1"
    unit      = "Bytes"
  }
}

resource "aws_cloudwatch_log_metric_filter" "high_volume_traffic" {
  name           = "VPCFlowLogs-HighVolumeTraffic"
  log_group_name = module.vpc[local.vpc_key].vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes, ...]"

  metric_transformation {
    name           = "HighVolumeTraffic"
    namespace      = "VPCFlowMetrics"
    value          = "1"
    default_value  = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "rejected_connections" {
  name           = "VPCFlowLogs-RejectedConnections"
  log_group_name = module.vpc[local.vpc_key].vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=REJECT,logstatus]"

  metric_transformation {
    name           = "RejectedConnections"
    namespace      = "VPCFlowMetrics"
    value          = "1"
    default_value  = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "ssh_connection_attempts" {
  name           = "VPCFlowLogs-SSHConnectionAttempts"
  log_group_name = module.vpc[local.vpc_key].vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport=22,protocol=6, ...]"

  metric_transformation {
    name      = "SSHConnectionAttempts"
    namespace = "VPCFlowMetrics"
    value     = "1"
  }
}
