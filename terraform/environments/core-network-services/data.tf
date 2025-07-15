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

# Data source to fetch information about the live VPC
data "aws_vpc" "live" {
  filter {
    name   = "tag:Name"
    values = ["live_data"]
  }
}

# Data source to fetch information about the non-live VPC
data "aws_vpc" "non_live" {
  filter {
    name   = "tag:Name"
    values = ["non_live_data"]
  }
}

# Data source to fetch existing NAT gateways in the live VPC
data "aws_nat_gateways" "live" {
  vpc_id = data.aws_vpc.live.id

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Data source to fetch existing NAT gateways in the non-live VPC
data "aws_nat_gateways" "non_live" {
  vpc_id = data.aws_vpc.non_live.id

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_sns_topic" "security_hub_arn" {
  name = "securityhub-alarms"
}
