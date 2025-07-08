data "aws_caller_identity" "current" {}

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
  name           = "AcceptedTrafficCount-${each.key}-${local.environment_management.account_ids[local.environment]}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=ACCEPT,logstatus]"

  metric_transformation {
    name      = "AcceptedTrafficCount-${local.environment_management.account_ids[local.environment]}"
    namespace = "VPCFlowLogs"
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_log_metric_filter" "rejected_connections" {
  for_each       = local.laa_vpc_existing
  name           = "VPCFlowLogs-RejectedConnections-${each.key}-${local.environment_management.account_ids[local.environment]}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport,protocol,packets,bytes,start,end,action=REJECT,logstatus]"

  metric_transformation {
    name          = "RejectedConnections-${local.environment_management.account_ids[local.environment]}"
    namespace     = "VPCFlowLogs"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_log_metric_filter" "ssh_connection_attempts" {
  for_each       = local.laa_vpc_existing
  name           = "VPCFlowLogs-SSHConnectionAttempts-${each.key}-${local.environment_management.account_ids[local.environment]}"
  log_group_name = each.value.vpc_flow_log
  pattern        = "[version,accountid,interfaceid,srcaddr,dstaddr,srcport,dstport=22,protocol=6,packets,bytes,start,end,action,logstatus]"

  metric_transformation {
    name      = "SSHConnectionAttempts-${local.environment_management.account_ids[local.environment]}"
    namespace = "VPCFlowLogs"
    value     = "1"
  }
}

# Cloudwatch metric alarms for above filters
resource "aws_cloudwatch_metric_alarm" "accepted_traffic_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "AcceptedTrafficAlarm-${each.key}-${local.environment_management.account_ids[local.environment]}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 3
  threshold_metric_id = "ad1"
  alarm_description   = "Anomaly detection alarm for accepted traffic in VPC '${each.key}' (${local.environment_management.account_ids[local.environment]}). A sudden spike or drop may indicate a network issue, service outage, or DDoS attempt."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.vpc_flowlog_alarms.arn]

  metric_query {
    id = "m1"
    metric {
      metric_name = "AcceptedTrafficCount-${local.environment_management.account_ids[local.environment]}"
      namespace   = "VPCFlowLogs"
      period      = 300
      stat        = "Sum"
    }
    return_data = true
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 1)"
    label       = "Sum AcceptedTrafficCount ${each.key} ${local.environment_management.account_ids[local.environment]} GreaterThanUpperThreshold 1.0"
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "rejected_connections_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "RejectedConnectionsAlarm-${each.key}-${local.environment_management.account_ids[local.environment]}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 3
  threshold_metric_id = "ad1"
  alarm_description   = "Anomaly detection alarm for rejected connections in VPC '${each.key}' (${local.environment_management.account_ids[local.environment]}). May indicate unauthorized access attempts, port scanning, or misconfigured security groups."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.vpc_flowlog_alarms.arn]

  metric_query {
    id = "m1"
    metric {
      metric_name = "RejectedConnections-${local.environment_management.account_ids[local.environment]}"
      namespace   = "VPCFlowLogs"
      period      = 300
      stat        = "Sum"
    }
    return_data = true
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "Sum RejectedConnections ${each.key} ${local.environment_management.account_ids[local.environment]} GreaterThanUpperThreshold 1.0"
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ssh_connection_attempts_alarm" {
  for_each            = local.laa_vpc_existing
  alarm_name          = "SSHConnectionAttemptsAlarm-${each.key}-${local.environment_management.account_ids[local.environment]}"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 3
  threshold_metric_id = "ad1"
  alarm_description   = "Anomaly detection alarm for SSH connection attempts (port 22) in VPC '${each.key}' (${local.environment_management.account_ids[local.environment]}). Indicates possible brute-force login attempts or unauthorized probing."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.vpc_flowlog_alarms.arn]

  metric_query {
    id = "m1"
    metric {
      metric_name = "SSHConnectionAttempts-${local.environment_management.account_ids[local.environment]}"
      namespace   = "VPCFlowLogs"
      period      = 300
      stat        = "Sum"
    }
    return_data = true
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "Sum SSHConnectionAttempts ${each.key} ${local.environment_management.account_ids[local.environment]} GreaterThanUpperThreshold 1.0"
    return_data = true
  }
}
# KMS key for SNS topic encryption
resource "aws_kms_key" "vpc_flowlog_sns_encryption" {
  description             = "KMS key for VPC Flow Log SNS topic encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow SNS to use the key",
        Effect = "Allow",
        Principal = {
          Service = "sns.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch to use the key",
        Effect = "Allow",
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "vpc-flowlog-sns-encryption-key"
  }
}

resource "aws_kms_alias" "vpc_flowlog_sns_topic" {
  name_prefix   = "alias/vpc-flowlog-sns-encryption"
  target_key_id = aws_kms_key.vpc_flowlog_sns_encryption.key_id
}

# SNS topic for VPC Flow Log alarms
resource "aws_sns_topic" "vpc_flowlog_alarms" {
  name              = "vpc-flowlog-alarms"
  kms_master_key_id = aws_kms_key.vpc_flowlog_sns_encryption.arn
  tags              = local.tags
}

# linking the sns topics to the pagerduty service
module "pagerduty_vpc_flowlog_alerts" {
  depends_on                = [aws_sns_topic.vpc_flowlog_alarms]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.vpc_flowlog_alarms.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}