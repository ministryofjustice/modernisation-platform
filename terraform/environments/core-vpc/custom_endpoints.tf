
# ---------------------------------------------------------------------------------------------------------------------------
# Terraform to create custom VPC Endpoints, Subnet & Security Group Associations.
# 
# This is used to create VPC endpoints that have subnet associations other than Protected. For example endpoints that are accessible from member account services or other MoJ Platforms.
# It also creates a dedicated, core-vpc-owned security group per business unit/environment and associates it with the shared VPC endpoint. 
# A dedicated SG (rather than the shared "endpoints" SG used by all consumers) keeps access grants isolated and auditable.
#
# NOTE: the security group MUST be owned by core-vpc (this account) - shared VPCs do not allow the VPC owner to attach a security group created by a participant account to
# resources it owns (see https://docs.aws.amazon.com/vpc/latest/userguide/vpc-share-limitations.html).
#
# ---------------------------------------------------------------------------------------------------------------------------

locals {
  vpc_endpoint_access = [
    {
      business_unit = "hmpps"
      environment   = "preproduction"
      cidr_block    = "172.20.0.0/16"
      port          = 443
      service_name  = "com.amazonaws.eu-west-2.execute-api"
      name          = "hmpps-preproduction-execute-api-cp-access"
      description   = "Allow Container Platform access to execute-api endpoint"
    },
    {
      business_unit = "hmpps"
      environment   = "production"
      cidr_block    = "172.20.0.0/16"
      port          = 443
      service_name  = "com.amazonaws.eu-west-2.execute-api"
      name          = "hmpps-production-execute-api-cp-access"
      description   = "Allow Container Platform access to execute-api endpoint"
    }
  ]

  vpc_endpoint_access_for_workspace = {
    for entry in local.vpc_endpoint_access :
    "${entry.business_unit}-${entry.environment}" => merge(entry, {
      vpc_name = "${entry.business_unit}-${entry.environment}"
    })
    if "core-vpc-${entry.environment}" == terraform.workspace
  }
}

# Plural "aws_vpc_endpoints" data source doesn't exist in this provider, so gate the singular
# lookup on the endpoint actually being configured for the VPC - otherwise it errors when missing.
locals {
  vpc_endpoint_access_existing = {
    for key, value in local.vpc_endpoint_access_for_workspace : key => value
    if contains(local.vpcs[terraform.workspace][value.vpc_name].options.additional_endpoints, value.service_name)
  }
}

data "aws_vpc_endpoint" "vpc_endpoint" {
  for_each = local.vpc_endpoint_access_existing

  vpc_id       = module.vpc[each.value.vpc_name].vpc_id
  service_name = each.value.service_name
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
  # for_each is scoped to endpoints that are actually configured so the association (and the SG it
  # depends on) is never removed just because the endpoint temporarily can't be found.
  for_each = local.vpc_endpoint_access_existing

  vpc_endpoint_id   = data.aws_vpc_endpoint.vpc_endpoint[each.key].id
  security_group_id = aws_security_group.vpc_endpoint_access[each.key].id
}