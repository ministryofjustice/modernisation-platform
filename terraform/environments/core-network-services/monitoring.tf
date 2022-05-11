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
  provider          = aws.aws-us-east-1
  name              = "route53_monitoring"

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

# hosted zone DDoS monitoring
resource "aws_cloudwatch_metric_alarm" "ddos_attack_modernisation_paltform_public_hosted_zone" {
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
