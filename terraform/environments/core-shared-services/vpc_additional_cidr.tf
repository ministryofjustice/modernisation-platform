# This additional CIDR and associated resources should be deleted once 10.20.0.0/16 is advertised internally
data "aws_availability_zones" "available" {}

locals {
  additional_subnet_cidr_map = {
    for az in data.aws_availability_zones.available.names :
    az => cidrsubnet(aws_vpc_ipv4_cidr_block_association.live-data-additional.cidr_block, 3, index(data.aws_availability_zones.available.names, az))
  }
  bidirectional_nacl_rules = {
    # Because NACLs offer two possible values for the egress attribute, egress=true means outbound, and egress=false means inbound
    # So to save duplicating the rules I've got two keys here to ensure inbound and outbound are rules can be done quickly
    "outbound" = true
    "inbound"  = false
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "live-data-additional" {
  cidr_block = "10.27.136.0/21"
  vpc_id     = module.vpc["live_data"].vpc_id
}

resource "aws_subnet" "live-data-additional" {
  for_each   = local.additional_subnet_cidr_map
  cidr_block = each.value
  vpc_id     = module.vpc["live_data"].vpc_id
  tags = merge({
    "Name" = format("live_data-additional-%s", each.key)
  },
  local.tags)
}

resource "aws_route_table" "live-data-additional" {
  vpc_id = module.vpc["live_data"].vpc_id
  tags = merge({
    "Name" = "live_data-additional"
  },
  local.tags)
}

resource "aws_route_table_association" "live-data-additional" {
  for_each       = aws_subnet.live-data-additional
  route_table_id = aws_route_table.live-data-additional.id
  subnet_id      = each.value["id"]
}

resource "aws_route" "default-via-tgw" {
  route_table_id         = aws_route_table.live-data-additional.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.transit-gateway.id
}

resource "aws_network_acl" "live-data-additional" {
  vpc_id     = module.vpc["live_data"].vpc_id
  subnet_ids = values(aws_subnet.live-data-additional)[*].id
  tags = merge({
    "Name" = "live_data-additional"
  },
  local.tags)
}

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "allow-vpc" {
  #checkov:skip=CKV_AWS_352:Verified
  for_each       = local.bidirectional_nacl_rules
  cidr_block     = module.vpc["live_data"].vpc_cidr_block
  egress         = each.value
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 1000
}

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "allow-vpc-additional" {
  #checkov:skip=CKV_AWS_352
  for_each       = local.bidirectional_nacl_rules
  cidr_block     = aws_vpc_ipv4_cidr_block_association.live-data-additional.cidr_block
  egress         = each.value
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 1100
}

# There's no deny east/west here because a number of VPCs will need to connect in.
# The DCs will be secured with security groups.

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "allow-10-0-0-0-8" {
  #checkov:skip=CKV_AWS_352
  for_each       = local.bidirectional_nacl_rules
  cidr_block     = "10.0.0.0/8"
  egress         = each.value
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 4000
}

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "allow-172-16-0-0-12" {
  #checkov:skip=CKV_AWS_352
  for_each       = local.bidirectional_nacl_rules
  cidr_block     = "172.16.0.0/12"
  egress         = each.value
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 4100
}

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "allow-192-168-0-0-16" {
  #checkov:skip=CKV_AWS_352
  for_each       = local.bidirectional_nacl_rules
  cidr_block     = "192.168.0.0/16"
  egress         = each.value
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 4200
}

#trivy:ignore:AVD-AWS-0102
#trivy:ignore:AVD-AWS-0105
resource "aws_network_acl_rule" "high-ports-in-from-internet" {
  cidr_block     = "0.0.0.0/0"
  egress         = false
  from_port      = 49152
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5300
  to_port        = 65535
}

resource "aws_network_acl_rule" "https-out-to-internet" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 443
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5000
  to_port        = 443
}

resource "aws_network_acl_rule" "http-out-to-internet" {
  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 80
  network_acl_id = aws_network_acl.live-data-additional.id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100
  to_port        = 80
}