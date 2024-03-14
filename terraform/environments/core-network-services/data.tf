data "aws_route" "non_live_data" {
  for_each = merge(
    module.vpc_inspection["non_live_data"].route_table_ids.transit_gateway,
    module.vpc_inspection["non_live_data"].route_table_ids.inspection,
    module.vpc_inspection["non_live_data"].route_table_ids.public
  )
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
}

data "aws_route" "live_data" {
  for_each = merge(
    module.vpc_inspection["live_data"].route_table_ids.transit_gateway,
    module.vpc_inspection["live_data"].route_table_ids.inspection,
    module.vpc_inspection["live_data"].route_table_ids.public
  )
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
}

data "aws_kms_key" "general_shared" {
  key_id = "arn:aws:kms:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:alias/general-platforms"
}