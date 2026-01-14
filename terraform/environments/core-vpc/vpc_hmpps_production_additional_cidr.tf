# Additional CIDR for hmpps-production VPC to address subnet capacity issues
# See: https://github.com/ministryofjustice/modernisation-platform/blob/main/cidr-allocation.md
# Primary CIDR: 10.27.8.0/21
# Secondary CIDR: 10.27.160.0/21

data "aws_availability_zones" "hmpps_production_available" {
  state = "available"
}

locals {
  # Only create these resources when in the core-vpc-production workspace
  create_hmpps_production_additional = terraform.workspace == "core-vpc-production" ? 1 : 0

  # Subdivide the secondary CIDR across availability zones
  # Creates 3 subnets per type (private, data, public) across 3 AZs
  hmpps_production_additional_subnet_cidr_map = {
    for az in data.aws_availability_zones.hmpps_production_available.names :
    az => cidrsubnet("10.27.160.0/21", 3, index(data.aws_availability_zones.hmpps_production_available.names, az))
  }

  # Bidirectional NACL rules helper
  hmpps_bidirectional_nacl_rules = {
    "outbound" = true
    "inbound"  = false
  }
}

# Associate secondary CIDR block to the hmpps-production VPC
resource "aws_vpc_ipv4_cidr_block_association" "hmpps_production_additional" {
  count = local.create_hmpps_production_additional

  cidr_block = "10.27.160.0/21"
  vpc_id     = module.vpc["hmpps-production"].vpc_id
}

# Create additional private subnets from the secondary CIDR
resource "aws_subnet" "hmpps_production_additional_private" {
  for_each = local.create_hmpps_production_additional == 1 ? local.hmpps_production_additional_subnet_cidr_map : {}

  availability_zone = each.key
  cidr_block        = each.value
  vpc_id            = module.vpc["hmpps-production"].vpc_id

  tags = merge(
    local.tags,
    {
      "Name" = "hmpps-production-general-private-additional-${each.key}"
    }
  )

  depends_on = [aws_vpc_ipv4_cidr_block_association.hmpps_production_additional]
}

# Create route table for additional private subnets
resource "aws_route_table" "hmpps_production_additional_private" {
  count = local.create_hmpps_production_additional

  vpc_id = module.vpc["hmpps-production"].vpc_id

  tags = merge(
    local.tags,
    {
      "Name" = "hmpps-production-additional-private"
    }
  )
}

# Associate route table with additional private subnets
resource "aws_route_table_association" "hmpps_production_additional_private" {
  for_each = aws_subnet.hmpps_production_additional_private

  route_table_id = aws_route_table.hmpps_production_additional_private[0].id
  subnet_id      = each.value.id
}

# Route all traffic via Transit Gateway
resource "aws_route" "hmpps_production_additional_default_via_tgw" {
  count = local.create_hmpps_production_additional

  route_table_id         = aws_route_table.hmpps_production_additional_private[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.transit-gateway.id
}

# Create Network ACL for additional private subnets
resource "aws_network_acl" "hmpps_production_additional_private" {
  count = local.create_hmpps_production_additional

  vpc_id     = module.vpc["hmpps-production"].vpc_id
  subnet_ids = [for subnet in aws_subnet.hmpps_production_additional_private : subnet.id]

  tags = merge(
    local.tags,
    {
      "Name" = "hmpps-production-additional-private"
    }
  )
}

# Allow traffic within the primary VPC CIDR
#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_allow_primary_vpc" {
  #checkov:skip=CKV_AWS_352:Verified - allows traffic within VPC
  for_each = local.create_hmpps_production_additional == 1 ? local.hmpps_bidirectional_nacl_rules : {}

  cidr_block     = "10.27.8.0/21" # Primary CIDR
  egress         = each.value
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 1000
}

# Allow traffic within the secondary VPC CIDR
#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_allow_secondary_vpc" {
  #checkov:skip=CKV_AWS_352:Verified - allows traffic within VPC
  for_each = local.create_hmpps_production_additional == 1 ? local.hmpps_bidirectional_nacl_rules : {}

  cidr_block     = "10.27.160.0/21" # Secondary CIDR
  egress         = each.value
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 1100
}

# Allow traffic from core-shared-services AD domain controllers
#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_allow_core_shared_services" {
  #checkov:skip=CKV_AWS_352:Verified - allows traffic from core-shared-services
  for_each = local.create_hmpps_production_additional == 1 ? local.hmpps_bidirectional_nacl_rules : {}

  cidr_block     = "10.27.136.0/21" # core-shared-services additional CIDR
  egress         = each.value
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 2010
}

# Deny east-west traffic to other MP environments (security boundary)
#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_deny_mp_cidr_in" {
  #checkov:skip=CKV_AWS_352:Verified - denies east-west traffic
  count = local.create_hmpps_production_additional

  cidr_block     = "10.26.0.0/15" # MP dev/test and prod/preprod ranges
  egress         = false
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "deny"
  rule_number    = 3000
}

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_deny_mp_cidr_out" {
  #checkov:skip=CKV_AWS_352:Verified - denies east-west traffic
  count = local.create_hmpps_production_additional

  cidr_block     = "10.26.0.0/15" # MP dev/test and prod/preprod ranges
  egress         = true
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "deny"
  rule_number    = 3000
}

# Allow RFC1918 private address space
#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_allow_10_0_0_0" {
  #checkov:skip=CKV_AWS_352:Verified - allows private address ranges
  for_each = local.create_hmpps_production_additional == 1 ? local.hmpps_bidirectional_nacl_rules : {}

  cidr_block     = "10.0.0.0/8"
  egress         = each.value
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 4000
}

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_allow_172_16_0_0" {
  #checkov:skip=CKV_AWS_352:Verified - allows private address ranges
  for_each = local.create_hmpps_production_additional == 1 ? local.hmpps_bidirectional_nacl_rules : {}

  cidr_block     = "172.16.0.0/12"
  egress         = each.value
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 4100
}

#trivy:ignore:AVD-AWS-0102
resource "aws_network_acl_rule" "hmpps_production_additional_allow_192_168_0_0" {
  #checkov:skip=CKV_AWS_352:Verified - allows private address ranges
  for_each = local.create_hmpps_production_additional == 1 ? local.hmpps_bidirectional_nacl_rules : {}

  cidr_block     = "192.168.0.0/16"
  egress         = each.value
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "-1"
  rule_action    = "allow"
  rule_number    = 4200
}

# Allow high ports inbound from internet (for responses to outbound connections)
#trivy:ignore:AVD-AWS-0102
#trivy:ignore:AVD-AWS-0105
resource "aws_network_acl_rule" "hmpps_production_additional_high_ports_in" {
  count = local.create_hmpps_production_additional

  cidr_block     = "0.0.0.0/0"
  egress         = false
  from_port      = 49152
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5300
  to_port        = 65535
}

# Allow HTTPS outbound to internet
resource "aws_network_acl_rule" "hmpps_production_additional_https_out" {
  count = local.create_hmpps_production_additional

  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 443
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5100
  to_port        = 443
}

# Allow HTTP outbound to internet
resource "aws_network_acl_rule" "hmpps_production_additional_http_out" {
  count = local.create_hmpps_production_additional

  cidr_block     = "0.0.0.0/0"
  egress         = true
  from_port      = 80
  network_acl_id = aws_network_acl.hmpps_production_additional_private[0].id
  protocol       = "tcp"
  rule_action    = "allow"
  rule_number    = 5200
  to_port        = 80
}

# Share additional subnets via RAM to member accounts
resource "aws_ram_resource_association" "hmpps_production_additional_private" {
  for_each = aws_subnet.hmpps_production_additional_private

  resource_arn       = each.value.arn
  resource_share_arn = module.resource-share["hmpps-production-general"].resource_share_arn
}
