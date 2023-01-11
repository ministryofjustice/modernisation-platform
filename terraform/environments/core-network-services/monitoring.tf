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
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=v1.0.0"
  sns_topics                = [aws_sns_topic.route53_monitoring.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["high_priority_alarms"]
}

module "pagerduty_transit_gateway_production" {
  depends_on = [
    aws_sns_topic.tgw_monitoring_production
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=v1.0.0"
  sns_topics                = [aws_sns_topic.tgw_monitoring_production.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["high_priority_alarms"]
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
data "aws_ec2_transit_gateway_vpc_attachment" "tranist_gateway_all"{
  for_each = toset(local.active_tgw_all_attachments)
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

resource "aws_cloudwatch_log_group" "transit_gateway_flowlog_group" {
  name = "tgw_flowlogs"
}

resource "aws_flow_log" "transit_gateway_flowlog" {
  for_each                      = merge(data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_production, data.aws_ec2_transit_gateway_peering_attachment.transit_gateway_production, data.aws_ec2_transit_gateway_vpc_attachment.transit_gateway_all)
  log_destination               = aws_cloudwatch_log_group.transit_gateway_flowlog_group.arn
  traffic_type                  = "ALL"
  transit_gateway_attachment_id = each.value["id"]
}