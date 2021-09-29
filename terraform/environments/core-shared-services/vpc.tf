locals {
  networking = {
    live_data     = "10.231.0.0/19"
    non_live_data = "10.231.32.0/19"
  }

  vpc_interface_endpoint_service_names = toset([
    "com.amazonaws.${data.aws_region.current_region.name}.imagebuilder",
    "com.amazonaws.${data.aws_region.current_region.name}.ec2messages",
    "com.amazonaws.${data.aws_region.current_region.name}.ssm",
    "com.amazonaws.${data.aws_region.current_region.name}.ssmmessages"
  ])

  vpc_gateway_endpoint_service_names = toset([
    "com.amazonaws.${data.aws_region.current_region.name}.s3"
  ])
}

module "vpc" {
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

  # Tags
  tags_common = local.tags
  tags_prefix = each.key
}

locals {
  # Derive non_live_data vpc and private subnets for configuration setting up the vpc endpoints
  non_live_data_vpc_id    = one([for k in module.vpc : k.vpc_id if k.vpc_cidr_block == local.networking.non_live_data])
  private_subnet_ids      = flatten([for k in module.vpc : k.non_tgw_subnet_ids_map.private if k.vpc_cidr_block == local.networking.non_live_data])

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
  private_route_tables = { for k in module.vpc : "private" => k.private_route_tables_map.private if k.vpc_cidr_block == local.networking.non_live_data }
  private_route_table_ids = [ for k,v in local.private_route_tables.private : v ]
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
  subnet_ids          = local.private_subnet_ids
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
  route_table_ids   = local.private_route_table_ids
  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-${each.value}"
    }
  )
}

