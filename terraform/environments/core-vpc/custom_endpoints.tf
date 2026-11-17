# ---------------------------------------------------------------------------------------------------------------------------
# Terraform to create custom VPC Endpoints and Security Group Associations.
#
# For each entry in the custom_endpoint_definitions local, this creates an Interface VPC endpoint (for the given service_name) owned
# directly by core-vpc, with subnet_ids set to the general-private subnets of the relevant member VPC, in each AZ (a, b, c)
# that the endpoint service supports.
#
# This is used for endpoints that need subnet placement other than Protected - e.g. endpoints that need to be accessible
# from member account services or other MoJ Platforms - and is independent of the member-vpc module's additional_endpoints.
#
# It also creates a dedicated, core-vpc-owned security group per entry and associates it with the endpoint.
# A dedicated SG (rather than the shared "endpoints" SG used by all consumers) keeps access grants isolated and auditable.
#
# NOTE: 
#
# - Each entry takes a "cidr_blocks" list, with one ingress rule created per CIDR on the security group. Include the member VPC's
#   own CIDR if intra-VPC traffic is needed, as a second endpoint with private DNS cannot be created for the same service in the same VPC.
#
# - The security group only controls network access to the endpoint, so every CIDR listed can reach everything served through it.
#   Finer-grained access must be enforced by the service itself, e.g. for execute-api, each private API's resource policy
#   (aws:SourceVpce / aws:SourceVpc / aws:VpcSourceIp conditions).
#
# - Entries default to the key "<business_unit>-<environment>". Set "key" when a VPC needs more than one endpoint.
#
# - the security group MUST be owned by core-vpc (this account) - shared VPCs do not allow the VPC owner to attach a security group created by a participant account to
# resources it owns (see https://docs.aws.amazon.com/vpc/latest/userguide/vpc-share-limitations.html).
#
# ---------------------------------------------------------------------------------------------------------------------------

locals {
  custom_endpoint_definitions = [
    {
      business_unit      = "hmpps"
      environment        = "development"
      cidr_blocks        = local.is-development ? ["172.20.0.0/16", module.vpc["hmpps-development"].vpc_cidr_block] : ["172.20.0.0/16"]
      port               = 443
      service_name       = "com.amazonaws.${data.aws_region.current.region}.execute-api"
      name               = "hmpps-development-execute-api-cp-access"
      description        = "Allow Container Platform access to execute-api endpoint"
      subnet_name_prefix = "general-private"
    },
    {
      business_unit      = "hmpps"
      environment        = "test"
      cidr_blocks        = local.is-test ? ["172.20.0.0/16", module.vpc["hmpps-test"].vpc_cidr_block] : ["172.20.0.0/16"]
      port               = 443
      service_name       = "com.amazonaws.${data.aws_region.current.region}.execute-api"
      name               = "hmpps-test-execute-api-cp-access"
      description        = "Allow Container Platform access to execute-api endpoint"
      subnet_name_prefix = "general-private"
    },
    {
      business_unit      = "hmpps"
      environment        = "preproduction"
      cidr_blocks        = local.is-preproduction ? ["172.20.0.0/16", module.vpc["hmpps-preproduction"].vpc_cidr_block] : ["172.20.0.0/16"]
      port               = 443
      service_name       = "com.amazonaws.${data.aws_region.current.region}.execute-api"
      name               = "hmpps-preproduction-execute-api-cp-access"
      description        = "Allow Container Platform access to execute-api endpoint"
      subnet_name_prefix = "general-private"
    },
    {
      business_unit      = "hmpps"
      environment        = "production"
      cidr_blocks        = local.is-production ? ["172.20.0.0/16", module.vpc["hmpps-production"].vpc_cidr_block] : ["172.20.0.0/16"]
      port               = 443
      service_name       = "com.amazonaws.${data.aws_region.current.region}.execute-api"
      name               = "hmpps-production-execute-api-cp-access"
      description        = "Allow Container Platform access to execute-api endpoint"
      subnet_name_prefix = "general-private"
    },
    {
      key                = "platforms-development-grafana-pdc-api"
      business_unit      = "platforms"
      environment        = "development"
      cidr_blocks        = ["10.26.16.0/21"]
      port               = 443
      service_name       = "com.amazonaws.vpce.eu-west-2.vpce-svc-0b12fa07b304f0d79"
      name               = "platforms-development-grafana-pdc-api"
      description        = "Allow Grafana PDC agents to reach the Grafana Cloud PDC API over PrivateLink"
      subnet_name_prefix = "general-private"
    },
    {
      key                = "platforms-development-grafana-pdc-gateway"
      business_unit      = "platforms"
      environment        = "development"
      cidr_blocks        = ["10.26.16.0/21"]
      port               = 22
      service_name       = "com.amazonaws.vpce.eu-west-2.vpce-svc-04a3bf37de7c4c8be"
      name               = "platforms-development-grafana-pdc-gateway"
      description        = "Allow Grafana PDC agents to reach the Grafana Cloud PDC SSH gateway over PrivateLink"
      subnet_name_prefix = "general-private"
    }
  ]

  # definitions for the current workspace's environment only, keyed by endpoint key
  custom_endpoints = {
    for entry in local.custom_endpoint_definitions :
    try(entry.key, "${entry.business_unit}-${entry.environment}") => merge(entry, {
      vpc_name = "${entry.business_unit}-${entry.environment}"
    })
    if "core-vpc-${entry.environment}" == terraform.workspace
  }

  # one entry per endpoint x ingress cidr block
  custom_endpoint_ingress_rules = {
    for entry in flatten([
      for key, value in local.custom_endpoints : [
        for cidr in distinct(value.cidr_blocks) : {
          key          = "${key}-${cidr}"
          endpoint_key = key
          cidr_block   = cidr
        }
      ]
    ]) : entry.key => entry
  }

  # member-vpc only ever creates subnets in the first 3 AZs (a, b, c) of the region, so exclude any others (e.g. eu-west-2d)
  custom_endpoint_availability_zones = [for az in sort(data.aws_availability_zones.available.names) : az if contains(["a", "b", "c"], substr(az, -1, 1))]

  # one entry per endpoint x availability zone, used to look up the subnet id in each az
  custom_endpoint_subnet_lookups = {
    for entry in flatten([
      for key, value in local.custom_endpoints : [
        for az in local.custom_endpoint_availability_zones : {
          key          = "${key}-${az}"
          endpoint_key = key
          vpc_name     = value.vpc_name
          name         = "${value.vpc_name}-${value.subnet_name_prefix}-${az}"
        }
      ]
    ]) : entry.key => entry
  }

  # subnet ids per endpoint (set on aws_vpc_endpoint.subnet_ids below), grouped back up from the per-az lookups above.
  # Only subnets in AZs that the endpoint service supports are used, as some third-party services don't cover every AZ.
  custom_endpoint_subnet_ids = {
    for key in keys(local.custom_endpoints) : key => [
      for subnet_key, subnet in local.custom_endpoint_subnet_lookups :
      data.aws_subnet.vpc_endpoint_access[subnet_key].id
      if subnet.endpoint_key == key && contains(data.aws_vpc_endpoint_service.vpc_endpoint_access[key].availability_zones, data.aws_subnet.vpc_endpoint_access[subnet_key].availability_zone)
    ]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

data "aws_subnet" "vpc_endpoint_access" {
  for_each = local.custom_endpoint_subnet_lookups

  vpc_id = module.vpc[each.value.vpc_name].vpc_id

  tags = {
    Name = each.value.name
  }
}

data "aws_vpc_endpoint_service" "vpc_endpoint_access" {
  for_each = local.custom_endpoints

  service_name = each.value.service_name
}

resource "aws_vpc_endpoint" "vpc_endpoint_access" {
  for_each = local.custom_endpoints

  vpc_id              = module.vpc[each.value.vpc_name].vpc_id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.custom_endpoint_subnet_ids[each.key]
  private_dns_enabled = true

  tags = merge(
    local.tags,
    {
      Name = "${each.value.business_unit}-${each.value.environment}-${each.value.service_name}"
    }
  )
}

resource "aws_security_group" "vpc_endpoint_access" {
  #checkov:skip=CKV2_AWS_5: "SG is associated with a VPC endpoint, not an EC2 instance"
  for_each = local.custom_endpoints

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
  for_each = local.custom_endpoint_ingress_rules

  security_group_id = aws_security_group.vpc_endpoint_access[each.value.endpoint_key].id
  description       = local.custom_endpoints[each.value.endpoint_key].description
  cidr_ipv4         = each.value.cidr_block
  from_port         = local.custom_endpoints[each.value.endpoint_key].port
  to_port           = local.custom_endpoints[each.value.endpoint_key].port
  ip_protocol       = "tcp"
}

resource "aws_vpc_endpoint_security_group_association" "vpc_endpoint_access" {
  for_each = local.custom_endpoints

  vpc_endpoint_id   = aws_vpc_endpoint.vpc_endpoint_access[each.key].id
  security_group_id = aws_security_group.vpc_endpoint_access[each.key].id
}
