locals {
  networking = {
    live_data     = "10.20.0.0/19"
    non_live_data = "10.20.32.0/19"
  }

  useful_vpc_ids = {
    for key in keys(local.networking) :
    key => {
      vpc_id                 = module.vpc_hub[key].vpc_id
      private_tgw_subnet_ids = module.vpc_hub[key].tgw_subnet_ids
    }
  }

  non_live__data_firewall_endpoint_map = {
    for sync_state in aws_networkfirewall_firewall.inline_inspection["non_live_data"].firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
  }

  live_data_firewall_endpoint_map = {
    for sync_state in aws_networkfirewall_firewall.inline_inspection["live_data"].firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
  }

}

module "vpc_hub" {
  for_each = local.networking

  source = "../../modules/vpc-hub"

  # CIDRs
  vpc_cidr = each.value

  # Private gateway type
  #   nat = NAT Gateway
  #   transit = Transit Gateway
  #   none = No gateway for internal traffic
  gateway = "nat"

  # VPC Flow Logs
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn

  # Transit Gateway ID
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  # Create inline firewall inspection endpoints
  inline_inspection = true

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

### Routes for inline_inspection = true
resource "aws_route" "non_live_data-transit-to-inspection" {
  for_each               = module.vpc_hub["non_live_data"].tgw_rtb_ids_and_azs
  route_table_id         = each.value.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.non_live_firewall_endpoint_map[each.value.availability_zone]
}

resource "aws_route" "live_data-transit-to-inspection" {
  for_each               = module.vpc_hub["live_data"].tgw_rtb_ids_and_azs
  route_table_id         = each.value.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.live_firewall_endpoint_map[each.value.availability_zone]
}