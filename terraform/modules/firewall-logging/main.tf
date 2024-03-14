resource "random_string" "main" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_networkfirewall_logging_configuration" "main" {
  firewall_arn = var.fw_arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.main.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "main" {
  #checkov:skip=CKV_AWS_158:Temporarily skip KMS encryption check while logging solution is being updated
  name              = format("%s-%s", var.cloudwatch_log_group_name, random_string.main.result)
  retention_in_days = 365 # 0 = never expire
  tags              = var.tags
}


module "firehose_delivery_stream" {
  source                  = "../../modules/firehose"
  resource_prefix         = var.fw_name
  firewall_name           = var.fw_name
  log_group_name          = aws_cloudwatch_log_group.main.name
  tags                    = var.tags
  xsiam_endpoint          = var.xsiam_firewall_endpoint
  xsiam_secret            = var.xsiam_firewall_secret
}


output "cloudwatch_log" {
  value       = aws_cloudwatch_log_group.main
  description = "The cloudwatch log created for the firewall"
}