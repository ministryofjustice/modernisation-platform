
# ---------------------------------------------------------------------------------------------------------------------------
# Terraform to create custom VPC Endpoints and Security Group Associations.
#
# For each entry in the vpc_endpoint_access local, this creates an Interface VPC endpoint (for the given service_name) owned
# directly by core-vpc, with subnet_ids set to the general-private subnets (across all three AZs) of the relevant member VPC.
#
# This is used for endpoints that need subnet placement other than Protected - e.g. endpoints that need to be accessible
# from member account services or other MoJ Platforms - and is independent of the member-vpc module's additional_endpoints.
#
# It also creates a dedicated, core-vpc-owned security group per business unit/environment and associates it with the endpoint.
# A dedicated SG (rather than the shared "endpoints" SG used by all consumers) keeps access grants isolated and auditable.
#
# NOTE: 
#
# - Currently supports just one ingress rule per security group.
#
# - the security group MUST be owned by core-vpc (this account) - shared VPCs do not allow the VPC owner to attach a security group created by a participant account to
# resources it owns (see https://docs.aws.amazon.com/vpc/latest/userguide/vpc-share-limitations.html).
#
# ---------------------------------------------------------------------------------------------------------------------------

locals {
  vpc_endpoint_access = [
    {
      business_unit      = "hmpps"
      environment        = "preproduction"
      cidr_block         = "172.20.0.0/16"
      port               = 443
      service_name       = "com.amazonaws.eu-west-2.execute-api"
      name               = "hmpps-preproduction-execute-api-cp-access"
      description        = "Allow Container Platform access to execute-api endpoint"
      subnet_name_prefix = "general-private"
    },
    {
      business_unit      = "hmpps"
      environment        = "production"
      cidr_block         = "172.20.0.0/16"
      port               = 443
      service_name       = "com.amazonaws.eu-west-2.execute-api"
      name               = "hmpps-production-execute-api-cp-access"
      description        = "Allow Container Platform access to execute-api endpoint"
      subnet_name_prefix = "general-private"
    }
  ]

  vpc_endpoint_access_for_workspace = {
    for entry in local.vpc_endpoint_access :
    "${entry.business_unit}-${entry.environment}" => merge(entry, {
      vpc_name = "${entry.business_unit}-${entry.environment}"
    })
    if "core-vpc-${entry.environment}" == terraform.workspace
  }

  # member-vpc only ever creates subnets in the first 3 AZs (a, b, c) of the region, so exclude any others (e.g. eu-west-2d)
  availability_zones = [for az in sort(data.aws_availability_zones.available.names) : az if contains(["a", "b", "c"], substr(az, -1, 1))]

  # one entry per vpc_endpoint_access entry x availability zone, used to look up the general-private subnet id in each az
  vpc_endpoint_access_subnets = {
    for entry in flatten([
      for key, value in local.vpc_endpoint_access_for_workspace : [
        for az in local.availability_zones : {
          key          = "${key}-${az}"
          endpoint_key = key
          vpc_name     = value.vpc_name
          name         = "${value.vpc_name}-${value.subnet_name_prefix}-${az}"
        }
      ]
    ]) : entry.key => entry
  }

  # subnet ids per endpoint (set on aws_vpc_endpoint.subnet_ids below), grouped back up from the per-az lookups above
  vpc_endpoint_access_subnet_ids = {
    for key in keys(local.vpc_endpoint_access_for_workspace) : key => [
      for subnet_key, subnet in local.vpc_endpoint_access_subnets :
      data.aws_subnet.vpc_endpoint_access[subnet_key].id
      if subnet.endpoint_key == key
    ]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "vpc_endpoint_access" {
  for_each = local.vpc_endpoint_access_subnets

  vpc_id = module.vpc[each.value.vpc_name].vpc_id

  tags = {
    Name = each.value.name
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint_access" {
  for_each = local.vpc_endpoint_access_for_workspace

  vpc_id              = module.vpc[each.value.vpc_name].vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.vpc_endpoint_access_subnet_ids[each.key]
  private_dns_enabled = true

  tags = merge(
    local.tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_security_group" "vpc_endpoint_access" {
  #checkov:skip=CKV2_AWS_5: "SG is associated with a VPC endpoint, not an EC2 instance"
  for_each = local.vpc_endpoint_access_for_workspace

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc[each.value.vpc_name].vpc_id

  tags = merge(
    local.tags,
    {
      Name = each.value.name
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_access" {
  for_each = local.vpc_endpoint_access_for_workspace

  security_group_id = aws_security_group.vpc_endpoint_access[each.key].id
  description       = each.value.description
  cidr_ipv4         = each.value.cidr_block
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = "tcp"
}

resource "aws_vpc_endpoint_security_group_association" "vpc_endpoint_access" {
  for_each = local.vpc_endpoint_access_for_workspace

  vpc_endpoint_id   = aws_vpc_endpoint.vpc_endpoint_access[each.key].id
  security_group_id = aws_security_group.vpc_endpoint_access[each.key].id
}