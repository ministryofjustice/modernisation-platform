######################
# Availability Zones #
######################
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az    = sort(data.aws_availability_zones.available.names)
  cidrs = cidrsubnets(var.vpc_cidr, 9, 9, 9, 4, 4, 4, 4, 4, 4, 4, 4, 4)
  types = ["public", "private", "data", "transit-gateway"]

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

  # NACLs
  nacl_rules = [
    { egress = false, action = "allow", protocol = -1, from_port = 0, to_port = 0, rule_num = 910, cidr = "0.0.0.0/0" },
    { egress = true, action = "allow", protocol = -1, from_port = 0, to_port = 0, rule_num = 910, cidr = "0.0.0.0/0" }
  ]

  # NACL rules with keys
  nacl_rules_expanded = {
    for rule in local.nacl_rules : join("-", values(rule)) => rule
  }
}

#######
# VPC #
#######
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr

  # Instance Tenancy
  instance_tenancy = "default"

  # DNS
  enable_dns_support   = true
  enable_dns_hostnames = true

  # ClassicLink
  enable_classiclink             = false
  enable_classiclink_dns_support = false

  # Turn off IPv6
  assign_generated_ipv6_cidr_block = false

  tags = merge(
    var.tags_common,
    {
      Name = var.tags_prefix
    }
  )
}

#################
# VPC Flow Logs #
#################
resource "aws_cloudwatch_log_group" "default" {
  name = "${var.tags_prefix}-vpc-flow-logs"
  tags = var.tags_common
}

resource "aws_flow_log" "cloudwatch" {
  iam_role_arn             = var.vpc_flow_log_iam_role
  log_destination          = aws_cloudwatch_log_group.default.arn
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  max_aggregation_interval = "60"
  vpc_id                   = aws_vpc.default.id

  tags = merge(
    {
      Name = "${var.tags_prefix}-vpc-flow-logs"
    }
  )
}

####################
# Internet Gateway #
####################
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

##################
# Public subnets #
##################
resource "aws_subnet" "public" {
  for_each = tomap(local.types_and_azs_and_cidrs.public)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}

# Public NACLs
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.public : subnet.id
  ]
}

# Public NACLs rules
resource "aws_network_acl_rule" "public" {
  for_each = local.nacl_rules_expanded

  network_acl_id = aws_network_acl.data.id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "public-local-ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "public-local-egress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

# Public route table assocation with public subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Public route
resource "aws_route" "public-internet-gateway" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
  route_table_id         = aws_route_table.public.id
}

###################
# Private subnets #
###################
resource "aws_subnet" "private" {
  for_each = tomap(local.types_and_azs_and_cidrs.private)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}

# Private NACLs
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.private : subnet.id
  ]
}

# Private NACLs rules
resource "aws_network_acl_rule" "private" {
  for_each = local.nacl_rules_expanded

  network_acl_id = aws_network_acl.data.id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "private-local-ingress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 210
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "private-local-egress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# Private route table
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.default.id
}

# Private route table assocation with private subnets
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.id].id
}

################
# Data subnets #
################
resource "aws_subnet" "data" {
  for_each = tomap(local.types_and_azs_and_cidrs.data)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}

# Data NACLs
resource "aws_network_acl" "data" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.data : subnet.id
  ]
}

# Data NACLs rules
resource "aws_network_acl_rule" "data" {
  for_each = local.nacl_rules_expanded

  network_acl_id = aws_network_acl.data.id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "data-local-ingress" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 210
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "data-local-egress" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# Data route table
resource "aws_route_table" "data" {
  for_each = aws_subnet.data

  vpc_id = aws_vpc.default.id
}

# Data route table assocation with data subnets
resource "aws_route_table_association" "data" {
  for_each = aws_subnet.data

  subnet_id      = each.value.id
  route_table_id = aws_route_table.data[each.value.id].id
}

###########################
# Transit Gateway subnets #
###########################
resource "aws_subnet" "transit-gateway" {
  for_each = tomap(local.types_and_azs_and_cidrs.transit-gateway)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az
}

# Transit Gateway NACLs
resource "aws_network_acl" "transit-gateway" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.transit-gateway : subnet.id
  ]
}

# Transit Gateway NACLs rules
resource "aws_network_acl_rule" "transit-gateway" {
  for_each = local.nacl_rules_expanded

  network_acl_id = aws_network_acl.data.id
  rule_number    = each.value.rule_num
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.action
  cidr_block     = each.value.cidr
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

resource "aws_network_acl_rule" "transit-gateway-local-ingress" {
  network_acl_id = aws_network_acl.transit-gateway.id
  rule_number    = 210
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

resource "aws_network_acl_rule" "transit-gateway-local-egress" {
  network_acl_id = aws_network_acl.transit-gateway.id
  rule_number    = 210
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# Transit Gateway route table
resource "aws_route_table" "transit-gateway" {
  for_each = aws_subnet.transit-gateway

  vpc_id = aws_vpc.default.id
}

# Transit Gateway route table assocation with transit-gateway subnets
resource "aws_route_table_association" "transit-gateway" {
  for_each = aws_subnet.transit-gateway

  subnet_id      = each.value.id
  route_table_id = aws_route_table.transit-gateway[each.value.id].id
}

###############
# NAT Gateway #
###############
resource "aws_eip" "public" {
  for_each = (var.gateway == "nat") ? aws_subnet.public : {}

  vpc = true
}

resource "aws_nat_gateway" "public" {
  for_each = (var.gateway == "nat") ? aws_subnet.public : {}

  allocation_id = aws_eip.public[each.value.id]
  subnet_id     = each.value.id
}

# Private NAT routes
resource "aws_route" "private-nat" {
  for_each = aws_nat_gateway.public

  route_table_id         = aws_route_table.private[each.value.id].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id
}

# Data NAT routes
resource "aws_route" "data-nat" {
  for_each = aws_nat_gateway.public

  route_table_id         = aws_route_table.data[each.value.id].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id
}

# Transit Gateway NAT routes
resource "aws_route" "transit-gateway-nat" {
  for_each = aws_nat_gateway.public

  route_table_id         = aws_route_table.transit-gateway[each.value.id].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id
}
