module "logging" {
  source                 = "../../modules/cloudwatch-firehose"
  cloudwatch_log_groups  = local.cloudwatch_log_groups
  destination_bucket_arn = local.cloudwatch_logging_bucket
  tags                   = local.tags
}