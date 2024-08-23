module "logging-vpc-flow-logs" {
  source                 = "../../modules/cloudwatch-firehose"
  for_each               = local.is-production ? { "build" = true } : {}
  cloudwatch_log_groups  = local.cloudwatch_vpc_flow_log_groups
  destination_bucket_arn = local.cloudwatch_log_buckets["vpc-flow-logs"]
  tags                   = local.tags
}

module "logging-generic-logs" {
  source                 = "../../modules/cloudwatch-firehose"
  for_each               = local.is-production ? { "build" = true } : {}
  cloudwatch_log_groups  = local.cloudwatch_generic_log_groups
  destination_bucket_arn = local.cloudwatch_log_buckets["generic-logs"]
  tags                   = local.tags
}