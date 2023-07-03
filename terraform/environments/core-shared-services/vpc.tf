locals {
  networking = {
    live_data     = "10.20.64.0/19"
    non_live_data = "10.20.96.0/19"
  }

  vpc_interface_endpoint_service_names = toset([
    "com.amazonaws.${data.aws_region.current_region.name}.ec2messages",
    "com.amazonaws.${data.aws_region.current_region.name}.imagebuilder",
    "com.amazonaws.${data.aws_region.current_region.name}.logs",
    "com.amazonaws.${data.aws_region.current_region.name}.ssm",
    "com.amazonaws.${data.aws_region.current_region.name}.ssmmessages"
  ])

  vpc_gateway_endpoint_service_names = toset([
    "com.amazonaws.${data.aws_region.current_region.name}.s3"
  ])
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
  vpc_flow_log_iam_role = data.aws_iam_role.vpc-flow-log.arn

  # Transit Gateway ID
  transit_gateway_id = data.aws_ec2_transit_gateway.transit-gateway.id

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

locals {
  # Derive non_live_data vpc and private subnets for configuration setting up the vpc endpoints
  non_live_data_vpc_id        = one([for k in module.vpc : k.vpc_id if k.vpc_cidr_block == local.networking.non_live_data])
  non_live_private_subnet_ids = flatten([for k in module.vpc : k.non_tgw_subnet_ids_map.private if k.vpc_cidr_block == local.networking.non_live_data])

  # Get the private route table keys and values, then transform the values (the actual route table ids) into a list
  # i.e. transform
  #   {
  #   "private" = {
  #     "non_live_data-private-eu-west-2a" = "rtb-aaa"
  #     "non_live_data-private-eu-west-2b" = "rtb-bbb"
  #     "non_live_data-private-eu-west-2c" = "rtb-ccc"
  #   },
  #   "data" = {
  #     "non_live_data-data-eu-west-2a" = "rtb-ddd"
  #     ...
  #   },
  #   {
  #   "transit-gateway" = {
  #     "non_live_data-transit-gateway-eu-west-2a" = "rtb-eee"
  #     ...
  #   }
  # }
  # to ["rtb-aaa", "rtb-bbb", "rtb-ccc"]
  non_live_private_route_tables    = { for k in module.vpc : "private" => k.private_route_tables_map.private if k.vpc_cidr_block == local.networking.non_live_data }
  non_live_private_route_table_ids = [for k, v in local.non_live_private_route_tables.private : v]
}

# Create security group for vpc endpoints
resource "aws_security_group" "interface_endpoint_security_group" {
  name        = "${local.application_name}-int-endpoint"
  description = "Security group to control traffic through vpc interface endpoints"
  vpc_id      = local.non_live_data_vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-int-endpoint"
    }
  )
}

resource "aws_security_group_rule" "interface_endpoint-security_group_rule" {
  description       = "Permit secure traffic to this endpoint within the VPC"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.networking.non_live_data]
  security_group_id = aws_security_group.interface_endpoint_security_group.id
}

# Create vpc interface endpoints in private subnets in non_live_data vpc
resource "aws_vpc_endpoint" "vpc_interface_endpoints" {
  for_each            = local.vpc_interface_endpoint_service_names
  vpc_id              = local.non_live_data_vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.non_live_private_subnet_ids
  security_group_ids  = [aws_security_group.interface_endpoint_security_group.id]
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-${each.value}"
    }
  )
}

resource "aws_vpc_endpoint" "vpc_gateway_endpoint_s3" {
  for_each          = local.vpc_gateway_endpoint_service_names
  vpc_endpoint_type = "Gateway"
  vpc_id            = local.non_live_data_vpc_id
  service_name      = each.value
  route_table_ids   = local.non_live_private_route_table_ids
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-${each.value}"
    }
  )
}

# Create security group for image builder
resource "aws_security_group" "image_builder_security_group" {
  name        = "${local.application_name}-image-builder" # checkov:skip=CKV2_AWS_5: "This will be attached to instances created via image builder"
  description = "Security group for image builder"
  vpc_id      = local.non_live_data_vpc_id
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-image-builder"
    }
  )
}

# tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "image_builder_egress_443" {
  description       = "Allow traffic from image builder instances"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.image_builder_security_group.id
}

# tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "image_builder_egress_80" {
  description       = "Allow traffic from image builder instances"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.image_builder_security_group.id
}
