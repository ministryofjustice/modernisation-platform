/**
 * # modernisation-platform-terraform-vpc-hub
 *
 * Terraform module to create a multi-tiered VPC for use with Transit Gateway.
 */

######################
# Availability Zones #
######################
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az    = sort(data.aws_availability_zones.available.names)
  cidrs = cidrsubnets(var.vpc_cidr, 9, 9, 9, 4, 4, 4, 4, 4, 4, 4, 4, 4)
  types = ["transit-gateway", "data", "private", "public"]

  # SAMPLE OUTPUT OF: types_and_az_and_cidrs

  # data            = {
  #     data-eu-west-2a = {
  #         az   = "eu-west-2a"
  #         cidr = "10.1.130.0/23"
  #           }
  #     data-eu-west-2b = {
  #         az   = "eu-west-2b"
  #         cidr = "10.1.132.0/23"
  #           }
  #     data-eu-west-2c = {
  #         az   = "eu-west-2c"
  #         cidr = "10.1.134.0/23"
  #           }
  #       }
  # private         = {
  #     private-eu-west-2a = {
  #         az   = "eu-west-2a"
  #         cidr = "10.1.136.0/23"
  #           }
  #     private-eu-west-2b = {
  #         az   = "eu-west-2b"
  #         cidr = "10.1.138.0/23"
  #           }
  #     private-eu-west-2c = {
  #         az   = "eu-west-2c"
  #         cidr = "10.1.140.0/23"
  #           }
  #       }

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

  # Turn off IPv6
  assign_generated_ipv6_cidr_block = false

  tags = merge(
    var.tags_common,
    {
      Name = var.tags_prefix
    }
  )
}

# Bring management of the default security group in the member vpc under terraform
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id

  # Block all inbound and outbound access to through this default security group
  ingress = []
  egress  = []

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-default"
    }
  )

  # For reference, the following inline ingress and egress rules are the 'default' rules which we are effectively removing
  # Uncomment these rules to restore an uncustomised, default security group back to what it was originally
  # See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/default-custom-security-groups.html#default-security-group for more info
  # ingress = [
  #   {
  #     protocol  = -1
  #     self      = true
  #     from_port = 0
  #     to_port   = 0
  #   }
  # ]

  # egress = [
  #   {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }
  # ]
}

#################
# VPC Flow Logs #
#################
# TF sec exclusions
# - Ignore warnings regarding log groups not encrypted using customer-managed KMS keys - following cost/benefit discussion and longer term plans for logging solution
#trivy:ignore:AVD-AWS-0017
resource "aws_cloudwatch_log_group" "default" {
  #checkov:skip=CKV_AWS_158:Temporarily skip KMS encryption check while logging solution is being updated
  name              = "${var.tags_prefix}-vpc-flow-logs"
  retention_in_days = 365
  tags              = var.tags_common
}

resource "aws_flow_log" "cloudwatch" {
  iam_role_arn             = var.vpc_flow_log_iam_role
  log_destination          = aws_cloudwatch_log_group.default.arn
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  max_aggregation_interval = "60"
  vpc_id                   = aws_vpc.default.id

  tags = merge(
    var.tags_common,
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

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-internet-gateway"
    }
  )
}

##################
# Public subnets #
##################
resource "aws_subnet" "public" {
  for_each = tomap(local.types_and_azs_and_cidrs.public)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Public NACLs
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.public : subnet.id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-public"
    }
  )
}

# Public NACLs rules
#trivy:ignore:AVD-AWS-0102
#trivy:ignore:AVD-AWS-0105
resource "aws_network_acl_rule" "public" {
  # checkov:skip=CKV_AWS_352:Ports need to be open
  for_each = local.public_access_acl_rules

  network_acl_id = aws_network_acl.public.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-public"
    }
  )
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

resource "aws_route" "public_mp_core" {
  count                  = var.gateway == "nat" ? 1 : 0
  destination_cidr_block = "10.20.0.0/16"
  route_table_id         = aws_route_table.public.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "public_mp_dev-test" {
  count                  = var.gateway == "nat" ? 1 : 0
  destination_cidr_block = "10.26.0.0/16"
  route_table_id         = aws_route_table.public.id
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "public_mp_prod-preprod" {
  count                  = var.gateway == "nat" ? 1 : 0
  destination_cidr_block = "10.27.0.0/16"
  route_table_id         = aws_route_table.public.id
  transit_gateway_id     = var.transit_gateway_id
}

###################
# Private subnets #
###################
resource "aws_subnet" "private" {
  for_each = tomap(local.types_and_azs_and_cidrs.private)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Private NACLs
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.private : subnet.id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-private"
    }
  )
}

# Private NACLs rules
#trivy:ignore:AVD-AWS-0102
#trivy:ignore:AVD-AWS-0105
resource "aws_network_acl_rule" "private" {
  for_each = local.static_acl_rules

  network_acl_id = aws_network_acl.private.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Private route table
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.default.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Private route table assocation with private subnets
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

################
# Data subnets #
################
resource "aws_subnet" "data" {
  for_each = tomap(local.types_and_azs_and_cidrs.data)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Data NACLs
resource "aws_network_acl" "data" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.data : subnet.id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-data"
    }
  )
}

# Data NACLs rules
#trivy:ignore:AVD-AWS-0102
#trivy:ignore:AVD-AWS-0105
resource "aws_network_acl_rule" "data" {
  for_each = local.static_acl_rules

  network_acl_id = aws_network_acl.data.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Data route table
resource "aws_route_table" "data" {
  for_each = aws_subnet.data

  vpc_id = aws_vpc.default.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Data route table assocation with data subnets
resource "aws_route_table_association" "data" {
  for_each = aws_subnet.data

  subnet_id      = each.value.id
  route_table_id = aws_route_table.data[each.key].id
}

###########################
# Transit Gateway subnets #
###########################
resource "aws_subnet" "transit-gateway" {
  for_each = tomap(local.types_and_azs_and_cidrs.transit-gateway)

  vpc_id = aws_vpc.default.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Transit Gateway NACLs
resource "aws_network_acl" "transit-gateway" {
  vpc_id = aws_vpc.default.id
  subnet_ids = [
    for subnet in aws_subnet.transit-gateway : subnet.id
  ]

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-transit-gateway"
    }
  )
}

# Transit Gateway NACLs rules
#trivy:ignore:AVD-AWS-0102
#trivy:ignore:AVD-AWS-0105
resource "aws_network_acl_rule" "transit-gateway" {
  # checkov:skip=CKV_AWS_229:Transit Gateway subnet NACL open by design
  # checkov:skip=CKV_AWS_230:Transit Gateway subnet NACL open by design
  # checkov:skip=CKV_AWS_231:Transit Gateway subnet NACL open by design
  # checkov:skip=CKV_AWS_232:Transit Gateway subnet NACL open by design
  # checkov:skip=CKV_AWS_352:Transit Gateway subnet NACL open by design
  for_each = local.transit_gateway_acl_rules

  network_acl_id = aws_network_acl.transit-gateway.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Transit Gateway route table
resource "aws_route_table" "transit-gateway" {
  for_each = aws_subnet.transit-gateway

  vpc_id = aws_vpc.default.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Transit Gateway route table assocation with transit-gateway subnets
resource "aws_route_table_association" "transit-gateway" {
  for_each = aws_subnet.transit-gateway

  subnet_id      = each.value.id
  route_table_id = aws_route_table.transit-gateway[each.key].id
}

###############
# NAT Gateway #
###############
resource "aws_eip" "public" {
  for_each = (var.gateway == "nat") ? aws_subnet.public : {}

  domain = "vpc"

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}-nat"
    }
  )
}

resource "aws_nat_gateway" "public" {
  for_each = (var.gateway == "nat") ? aws_subnet.public : {}

  allocation_id = aws_eip.public[each.key].id
  subnet_id     = each.value.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-${each.key}"
    }
  )
}

# Route back to MP via TGW

# Private Routes
resource "aws_route" "private-nat" {
  for_each = (var.gateway == "nat") ? aws_route_table.private : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[replace(each.key, "private", "public")].id
}

resource "aws_route" "private-tgw" {
  for_each = (var.gateway == "transit") ? aws_route_table.private : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

# Data routes
resource "aws_route" "data-nat" {
  for_each = (var.gateway == "nat") ? aws_route_table.data : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[replace(each.key, "data", "public")].id
}

resource "aws_route" "data-tgw" {
  for_each = (var.gateway == "transit") ? aws_route_table.data : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}

# Transit Gateway NAT routes
resource "aws_route" "transit-gateway-nat" {
  for_each = (var.gateway == "nat") ? aws_route_table.transit-gateway : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[replace(each.key, "transit-gateway", "public")].id
}

resource "aws_route" "transit-gateway-tgw" {
  for_each = (var.gateway == "transit") ? aws_route_table.transit-gateway : {}

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.transit_gateway_id
}