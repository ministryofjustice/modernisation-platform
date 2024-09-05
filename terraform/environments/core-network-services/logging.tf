module "logging-vpc-flow-logs" {
  source                      = "github.com/ministryofjustice/modernisation-platform-terraform-aws-data-firehose?ref=c734a2e83c8b034a07b6d11e1975c4f230f42ec4" #v1.0.0
  for_each                    = local.is-production ? { "build" = true } : {}
  cloudwatch_log_group_names  = local.cloudwatch_vpc_flow_log_groups
  destination_bucket_arn      = local.cloudwatch_log_buckets["vpc-flow-logs"]
  tags                        = local.tags
}

module "logging-generic-logs" {
  source                      = "github.com/ministryofjustice/modernisation-platform-terraform-aws-data-firehose?ref=c734a2e83c8b034a07b6d11e1975c4f230f42ec4" #v1.0.0
  for_each                    = local.is-production ? { "build" = true } : {}
  cloudwatch_log_group_names  = local.cloudwatch_generic_log_groups
  destination_bucket_arn      = local.cloudwatch_log_buckets["generic-logs"]
  tags                        = local.tags
}