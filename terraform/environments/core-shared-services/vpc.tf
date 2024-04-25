locals {
  networking = {
    live_data     = "10.20.64.0/19"
    non_live_data = "10.20.96.0/19"
  }

  vpc_interface_endpoint_service_names = [
    "com.amazonaws.${data.aws_region.current_region.name}.ec2messages",
    "com.amazonaws.${data.aws_region.current_region.name}.imagebuilder",
    "com.amazonaws.${data.aws_region.current_region.name}.logs",
    "com.amazonaws.${data.aws_region.current_region.name}.ssm",
    "com.amazonaws.${data.aws_region.current_region.name}.ssmmessages"
  ]

  vpc_gateway_endpoint_service_names = [
    "com.amazonaws.${data.aws_region.current_region.name}.s3"
  ]
}

module "vpc" {
  #checkov:skip=CKV_TF_1:Local reference
  for_each = local.networking
  source   = "../../modules/vpc-hub"

  # CIDRs
  vpc_cidr = each.value

  # private gateway type
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

locals {
  private_route_tables = {
    for key in keys(local.networking) :
    key => values(module.vpc[key].private_route_tables_map.private)
  }

  vpc_interface_endpoints = {
    for value in setproduct(keys(local.networking), local.vpc_interface_endpoint_service_names) :
    "${value[0]}-${value[1]}" => {
      vpc_name      = value[0],
      endpoint_name = value[1]
    }
  }

  vpc_gateway_endpoints = {
    for value in setproduct(keys(local.networking), local.vpc_gateway_endpoint_service_names) :
    "${value[0]}-${value[1]}" => {
      vpc_name      = value[0],
      endpoint_name = value[1]
    }
  }
}

resource "aws_vpc_endpoint" "vpc_interface_endpoints" {
  for_each            = local.vpc_interface_endpoints
  vpc_id              = module.vpc[each.value.vpc_name].vpc_id
  service_name        = each.value.endpoint_name
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = module.vpc[each.value.vpc_name].non_tgw_subnet_ids_map["private"]
  security_group_ids  = [aws_security_group.interface_endpoint_security_group[each.value.vpc_name].id]
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-${each.value.endpoint_name}"
    }
  )
}

resource "aws_vpc_endpoint" "vpc_gateway_endpoints" {
  for_each          = local.vpc_gateway_endpoints
  vpc_endpoint_type = "Gateway"
  vpc_id            = module.vpc[each.value.vpc_name].vpc_id
  service_name      = each.value.endpoint_name
  route_table_ids   = local.private_route_tables[each.value.vpc_name]
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-${each.value.endpoint_name}"
    }
  )
}

# Create security group for vpc endpoints
resource "aws_security_group" "interface_endpoint_security_group" {
  for_each    = module.vpc
  name        = "${local.application_name}-int-endpoint"
  description = "Security group to control traffic through vpc interface endpoints"
  vpc_id      = each.value.vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-int-endpoint"
    }
  )
}

resource "aws_security_group_rule" "interface_endpoint-security_group_rule" {
  for_each          = module.vpc
  description       = "Permit secure traffic to this endpoint within the VPC"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.value.vpc_cidr_block]
  security_group_id = aws_security_group.interface_endpoint_security_group[each.key].id
}

# Create security group for image builder
resource "aws_security_group" "image_builder_security_group" {
  for_each    = module.vpc
  name        = "${local.application_name}-image-builder" # checkov:skip=CKV2_AWS_5: "This will be attached to instances created via image builder"
  description = "Security group for image builder"
  vpc_id      = module.vpc[each.key].vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-image-builder"
    }
  )
}

# tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "image_builder_egress_443" {
  for_each          = module.vpc
  description       = "Allow traffic from image builder instances"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.image_builder_security_group[each.key].id
}

# tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "image_builder_egress_80" {
  for_each          = module.vpc
  description       = "Allow traffic from image builder instances"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.image_builder_security_group[each.key].id
}
