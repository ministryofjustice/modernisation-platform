# monitoring for aws config, cloudtrail, security hub
module "core_monitoring" {
  source                     = "../../modules/core-monitoring"
  pagerduty_integration_keys = local.pagerduty_integration_keys
}

# Route53 monitoring

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

module "pagerduty_transit_gateway_production" {
  depends_on = [
    aws_sns_topic.tgw_monitoring_production
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.tgw_monitoring_production.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["tgw_cloudwatch"]
}

# hosted zone DDoS monitoring
resource "aws_cloudwatch_metric_alarm" "ddos_attack_modernisation_platform_public_hosted_zone" {
  provider = aws.aws-us-east-1

  alarm_name          = "DDoSDetected-modernisation-platform-public-hosted-zone"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "20"
  metric_name         = "DDoSDetected"
  namespace           = "AWS/DDoSProtection"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm for DDoS events detected on resource ${aws_route53_zone.modernisation-platform.arn}"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.route53_monitoring.arn]
  dimensions = {
    ResourceArn = aws_route53_zone.modernisation-platform.arn
  }
  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "ddos_attack_application_public_hosted_zone" {
  for_each = aws_route53_zone.application_zones
  provider = aws.aws-us-east-1

  alarm_name          = "DDoSDetected-${each.value.tags.Name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "20"
  metric_name         = "DDoSDetected"
  namespace           = "AWS/DDoSProtection"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm for DDoS events detected on resource ${each.value.arn}"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.route53_monitoring.arn]
  dimensions = {
    ResourceArn = each.value.arn
  }
  tags = local.tags
}

## Transit Gateway monitoring
data "aws_ec2_transit_gateway_peering_attachment" "transit_gateway_production" {
  for_each = toset(local.active_tgw_peering_attachments)
  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

data "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_production" {
  for_each = toset(local.active_tgw_vpc_attachments)
  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

resource "aws_cloudwatch_metric_alarm" "production_attachment_no_traffic_5_minutes" {
  for_each            = merge(data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_production, data.aws_ec2_transit_gateway_peering_attachment.transit_gateway_production)
  alarm_actions       = [aws_sns_topic.tgw_monitoring_production.arn]
  alarm_description   = format("Low traffic detected for VPC attachment %s", each.value.tags.Name)
  alarm_name          = format("NoVPCAttachmentTraffic-%s", each.value.tags.Name)
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = "15"
  dimensions = {
    TransitGateway           = aws_ec2_transit_gateway.transit-gateway.id
    TransitGatewayAttachment = each.value["id"]
  }
  evaluation_periods = "15"
  metric_name        = "BytesIn"
  namespace          = "AWS/TransitGateway"
  period             = "60"
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "breaching"
  tags               = local.tags
}

# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "tgw_monitoring_production" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  name = "tgw_monitoring_production"

  tags = local.tags
}

# TF sec exclusions
# - Ignore warnings regarding log groups not encrypted using customer-managed KMS keys - following cost/benefit discussion and longer term plans for logging solution
#tfsec:ignore:AWS089
resource "aws_cloudwatch_log_group" "tgw_flowlog_group" {
  #checkov:skip=CKV_AWS_158:Temporarily skip KMS encryption check while logging solution is being
  name              = "tgw-flowlogs"
  retention_in_days = 365 # 0 = never expire
  #kms_key_id        = aws_kms_key.environment_logging.arn
  tags = local.tags
}

resource "aws_flow_log" "tgw_flowlog" {
  depends_on                    = [aws_cloudwatch_log_group.tgw_flowlog_group]
  for_each                      = merge(data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_all, data.aws_ec2_transit_gateway_peering_attachment.transit_gateway_production)
  iam_role_arn                  = aws_iam_role.vpc_flow_log.arn
  log_destination               = aws_cloudwatch_log_group.tgw_flowlog_group.arn
  log_destination_type          = "cloud-watch-logs"
  traffic_type                  = "ALL"
  max_aggregation_interval      = "60"
  transit_gateway_attachment_id = each.value["id"]
  tags                          = local.tags
}

resource "aws_cloudwatch_metric_alarm" "firewall-traffic-drop-alarm" {
  alarm_name          = "firewall-traffic-dropped"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "DroppedPackets"
  namespace           = "AWS/NetworkFirewall"
  period              = 300
  evaluation_periods  = 10
  alarm_description   = "Dropped packets alarm"
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.networking_general.arn]
  # Will be populated with a sns topic however currently need to either create a new one or use tgw_monitoring_production or route53_monitoring
  insufficient_data_actions = []
  dimensions = {
    AvailabilityZone = "eu-west-2"
    FirewallName     = aws_networkfirewall_firewall.external_inspection.name
  }
}

# tfsec:ignore:aws-sns-enable-topic-encryption as encrypted topics do not work with pagerduty subscription
resource "aws_sns_topic" "networking_general" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  name = "networking_general"
  tags = local.tags
}

# subscribe to the sns topic to the pagerduty service
module "pagerduty_networking_general" {
  depends_on = [
    aws_sns_topic.networking_general
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.networking_general.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["networking_cloudwatch"]
}
