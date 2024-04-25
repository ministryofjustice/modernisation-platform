locals {
  networking = {
    live_data     = "10.20.128.0/19"
    non_live_data = "10.20.160.0/19"
  }
}

module "vpc" {
  #checkov:skip=CKV_TF_1:Local reference
  for_each = local.networking
  source   = "../../modules/vpc-hub"

  # CIDRs
  vpc_cidr = each.value

  # Gateway type
  #   nat = Nat Gateway
  #   transit = Transit Gateway
  #   none = no gateway for internal traffic
  gateway = "transit"

  # VPC Flow Logs
  vpc_flow_log_iam_role = aws_iam_role.vpc_flow_log.arn

  # Transit Gateway ID
  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}