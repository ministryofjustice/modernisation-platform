module "logging-generic-logs" {
  source                     = "github.com/ministryofjustice/modernisation-platform-terraform-aws-data-firehose?ref=2e58c8fd0b43ca8461dfd0c8cc5f43a1a9c49987" #v1.1.0
  for_each                   = local.is-production ? { "build" = true } : {}
  cloudwatch_log_group_names = local.cloudwatch_generic_log_groups
  destination_bucket_arn     = local.cloudwatch_log_buckets["generic-logs"]
  tags                       = local.tags
}