module "logging-r53-resolver" {
  source                 = "../../modules/cloudwatch-firehose"
  for_each               = local.is-production ? { "build" = true } : {}
  cloudwatch_log_groups  = local.cloudwatch_r53_resolver_log_groups
  destination_bucket_arn = local.cloudwatch_log_buckets["r53-resolver-logs"]
  tags                   = local.tags
}

module "logging-vpc-flow-logs" {
  source                 = "../../modules/cloudwatch-firehose"
  for_each               = local.is-production ? { "build" = true } : {}
  cloudwatch_log_groups  = local.cloudwatch_vpc_flow_log_groups
  destination_bucket_arn = local.cloudwatch_log_buckets["vpc-flow-logs"]
  tags                   = local.tags
}
