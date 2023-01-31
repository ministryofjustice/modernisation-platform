module "core_monitoring" {
  source                     = "../../modules/core-monitoring"
  pagerduty_integration_keys = local.pagerduty_integration_keys
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "aws_route53_logs_com" {
  provider = aws.us-east-1

  name              = "aws_route53_zone.logs_com.name"
  retention_in_days = 365
}