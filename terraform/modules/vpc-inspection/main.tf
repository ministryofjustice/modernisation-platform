data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az    = sort(data.aws_availability_zones.available.names)
  cidrs = cidrsubnets(var.vpc_cidr, 9, 9, 9, 9, 9, 9, 4, 4, 4)
  types = ["transit-gateway", "inspection", "public"]

  types_and_azs_and_cidrs = {
    for index, type in local.types :
    type => {
      for cidr_index, cidr in slice(local.cidrs, index * 3, index * 3 + 3) :
      "${type}-${local.az[cidr_index]}" => {
        cidr = cidr
        az   = local.az[cidr_index]
      }
    }
  }

  firewall_endpoint_map = {
    for sync_state in aws_networkfirewall_firewall.inline_inspection.firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
  }

  # Custom VPC flow log statement
  custom_flow_log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"

}

### VPC ###
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = merge(
    var.tags_common,
    { Name = var.tags_prefix }
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}

### VPC Flow Logs ###
resource "random_string" "main" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_cloudwatch_log_group" "main" {
  #checkov:skip=CKV_AWS_158:Temporarily skip KMS encryption check while logging solution is being updated
  kms_key_id        = length(var.cloudwatch_kms_key_id) > 1 ? var.cloudwatch_kms_key_id : null
  name              = format("%s-vpc-flow-logs-%s", var.tags_prefix, random_string.main.result)
  retention_in_days = 365

  tags = var.tags_common
}

resource "aws_flow_log" "cloudwatch" {
  iam_role_arn             = var.vpc_flow_log_iam_role
  log_destination          = aws_cloudwatch_log_group.main.arn
  log_destination_type     = "cloud-watch-logs"
  log_format               = local.custom_flow_log_format
  traffic_type             = "ALL"
  max_aggregation_interval = "60"
  vpc_id                   = aws_vpc.main.id

  tags = merge(
    var.tags_common,
    { Name = format("%s-vpc-flow-logs", var.tags_prefix) }
  )
}

resource "aws_flow_log" "s3" {
  for_each                 = var.flow_log_s3_destination_arn != "" ? toset([var.flow_log_s3_destination_arn]) : toset([])
  log_destination          = each.key
  log_destination_type     = "s3"
  log_format               = local.custom_flow_log_format
  max_aggregation_interval = "60"
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.main.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-vpc-flow-logs-s3-${random_string.main.result}"
    }
  )
}

### Transit Gateway Subnets ###
resource "aws_subnet" "transit-gateway" {
  for_each          = tomap(local.types_and_azs_and_cidrs.transit-gateway)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s", var.tags_prefix, each.key) }
  )
}

resource "aws_route_table" "transit-gateway" {
  for_each = aws_subnet.transit-gateway
  vpc_id   = aws_vpc.main.id

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s", var.tags_prefix, each.key) }
  )
}

resource "aws_route_table_association" "transit-gateway" {
  for_each       = aws_subnet.transit-gateway
  route_table_id = aws_route_table.transit-gateway[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route" "transit-gateway-0-0-0-0" {
  depends_on             = [aws_networkfirewall_firewall.inline_inspection]
  for_each               = aws_route_table.transit-gateway
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = each.value.id
  vpc_endpoint_id        = local.firewall_endpoint_map[aws_subnet.transit-gateway[each.key].availability_zone]
}

resource "aws_route" "transit-gateway-10-20-0-0" {
  for_each               = aws_route_table.transit-gateway
  destination_cidr_block = "10.20.0.0/16"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "transit-gateway-10-26-0-0" {
  for_each               = aws_route_table.transit-gateway
  destination_cidr_block = "10.26.0.0/16"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "transit-gateway-10-27-0-0" {
  for_each               = aws_route_table.transit-gateway
  destination_cidr_block = "10.27.0.0/16"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "transit-gateway-10-231-0-0" {
  for_each               = aws_route_table.transit-gateway
  destination_cidr_block = "10.231.0.0/20"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_network_acl" "transit-gateway" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.transit-gateway : subnet.id]

  tags = merge(
    var.tags_common,
    { Name = format("%s-transit-gateway", var.tags_prefix) }
  )
}

#trivy:ignore:avd-aws-0102
#trivy:ignore:avd-aws-0105
resource "aws_network_acl_rule" "transit-gateway" {
  #checkov:skip=CKV_AWS_229:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_230:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_231:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_232:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_352:NACL rules open as firewall applies controls
  for_each = local.static_acl_rules

  network_acl_id = aws_network_acl.transit-gateway.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

### Inspection Subnets ###
resource "aws_subnet" "inspection" {
  for_each          = tomap(local.types_and_azs_and_cidrs.inspection)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s", var.tags_prefix, each.key) }
  )
}

resource "aws_route_table" "inspection" {
  for_each = aws_subnet.inspection
  vpc_id   = aws_vpc.main.id

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s", var.tags_prefix, each.key) }
  )
}

resource "aws_route_table_association" "inspection" {
  for_each       = aws_subnet.inspection
  route_table_id = aws_route_table.inspection[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route" "inspection-0-0-0-0" {
  for_each               = aws_route_table.inspection
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = each.value.id
  nat_gateway_id         = aws_nat_gateway.public[replace(each.key, "inspection", "public")].id
}

resource "aws_route" "inspection-10-20-0-0" {
  for_each               = aws_route_table.inspection
  destination_cidr_block = "10.20.0.0/16"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "inspection-10-26-0-0" {
  for_each               = aws_route_table.inspection
  destination_cidr_block = "10.26.0.0/16"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "inspection-10-27-0-0" {
  for_each               = aws_route_table.inspection
  destination_cidr_block = "10.27.0.0/16"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "inspection-10-231-0-0" {
  for_each               = aws_route_table.inspection
  destination_cidr_block = "10.231.0.0/20"
  route_table_id         = each.value.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_network_acl" "inspection" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.inspection : subnet.id]

  tags = merge(
    var.tags_common,
    { Name = format("%s-inspection", var.tags_prefix) }
  )
}

#trivy:ignore:avd-aws-0102
#trivy:ignore:avd-aws-0105
resource "aws_network_acl_rule" "inspection" {
  #checkov:skip=CKV_AWS_229:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_230:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_231:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_232:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_352:NACL rules open as firewall applies controls
  for_each = local.static_acl_rules

  network_acl_id = aws_network_acl.inspection.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

### Public Subnets ###
resource "aws_subnet" "public" {
  for_each          = tomap(local.types_and_azs_and_cidrs.public)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s", var.tags_prefix, each.key) }
  )
}

resource "aws_route_table" "public" {
  for_each = aws_subnet.public
  vpc_id   = aws_vpc.main.id

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s", var.tags_prefix, each.key) }
  )
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  route_table_id = aws_route_table.public[each.key].id
  subnet_id      = each.value.id
}

resource "aws_route" "public-0-0-0-0" {
  for_each               = aws_route_table.public
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = each.value.id
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_route" "public-10-20-0-0" {
  depends_on             = [aws_networkfirewall_firewall.inline_inspection]
  for_each               = aws_route_table.public
  destination_cidr_block = "10.20.0.0/16"
  route_table_id         = each.value.id
  vpc_endpoint_id        = local.firewall_endpoint_map[aws_subnet.public[each.key].availability_zone]
}

resource "aws_route" "public-10-26-0-0" {
  depends_on             = [aws_networkfirewall_firewall.inline_inspection]
  for_each               = aws_route_table.public
  destination_cidr_block = "10.26.0.0/16"
  route_table_id         = each.value.id
  vpc_endpoint_id        = local.firewall_endpoint_map[aws_subnet.public[each.key].availability_zone]
}

resource "aws_route" "public-10-27-0-0" {
  depends_on             = [aws_networkfirewall_firewall.inline_inspection]
  for_each               = aws_route_table.public
  destination_cidr_block = "10.27.0.0/16"
  route_table_id         = each.value.id
  vpc_endpoint_id        = local.firewall_endpoint_map[aws_subnet.public[each.key].availability_zone]
}

resource "aws_route" "public-10-231-0-0" {
  depends_on             = [aws_networkfirewall_firewall.inline_inspection]
  for_each               = aws_route_table.public
  destination_cidr_block = "10.231.0.0/20"
  route_table_id         = each.value.id
  vpc_endpoint_id        = local.firewall_endpoint_map[aws_subnet.public[each.key].availability_zone]
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for subnet in aws_subnet.public : subnet.id]

  tags = merge(
    var.tags_common,
    { Name = format("%s-public", var.tags_prefix) }
  )
}

#trivy:ignore:avd-aws-0102
#trivy:ignore:avd-aws-0105
resource "aws_network_acl_rule" "public" {
  #checkov:skip=CKV_AWS_229:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_230:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_231:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_232:NACL rules open as firewall applies controls
  #checkov:skip=CKV_AWS_352:NACL rules open as firewall applies controls
  for_each = local.static_acl_rules

  network_acl_id = aws_network_acl.public.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

### AWS Gateways ###
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags_common,
    { Name = format("%s-internet-gateway", var.tags_prefix) }
  )
}

resource "aws_eip" "public" {
  #checkov:skip=CKV2_AWS_19:EIPs are allocated to NAT gateways
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s-nat", var.tags_prefix, each.key) }
  )
}

resource "aws_nat_gateway" "public" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.public[each.key].id
  subnet_id     = each.value.id

  tags = merge(
    var.tags_common,
    { Name = format("%s-%s", var.tags_prefix, each.key) }
  )
}
