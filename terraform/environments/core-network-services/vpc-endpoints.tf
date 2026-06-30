locals {
  centralised_endpoint_vpc_cidr = "10.20.240.0/20"

  centralised_endpoint_consumer_accounts = {
    cloud-platform-development      = local.environment_management.account_ids["cloud-platform-development"]
    cloud-platform-preproduction    = local.environment_management.account_ids["cloud-platform-preproduction"]
    cloud-platform-live             = local.environment_management.account_ids["cloud-platform-live"]
    container-platform-octo-nonlive = local.environment_management.account_ids["container-platform-octo-nonlive"]
    container-platform-octo-live    = local.environment_management.account_ids["container-platform-octo-live"]
  }

  centralised_endpoint_configuration = jsondecode(file("${path.module}/centralised-vpc-endpoints.json"))

  centralised_interface_endpoint_services = {
    for endpoint_name in toset(local.centralised_endpoint_configuration.interface_endpoint_names) :
    replace(endpoint_name, ".", "_") => "com.amazonaws.${data.aws_region.current.region}.${endpoint_name}"
  }

  centralised_endpoint_service_private_dns_zones = {
    for service_name, service in local.centralised_interface_endpoint_services :
    service_name => "${replace(service, "com.amazonaws.${data.aws_region.current.region}.", "")}.${data.aws_region.current.region}.amazonaws.com"
  }
}

module "vpc_centralised_endpoints" {
  source = "../../modules/vpc-hub"

  # CIDRs
  vpc_cidr = local.centralised_endpoint_vpc_cidr

  # private gateway type
  #   nat = Nat Gateway
  #   transit = Transit Gateway
  #   none = no gateway for internal traffic
  gateway = "transit"

  # VPC Flow Logs
  vpc_flow_log_iam_role       = aws_iam_role.vpc_flow_log.arn
  flow_log_s3_destination_arn = local.core_logging_bucket_arns["vpc-flow-logs"]

  # Transit Gateway ID
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  # Tags
  tags_common = local.tags
  tags_prefix = "centralised-endpoints"
}

resource "aws_security_group" "centralised_endpoint_interface" {
  name        = "${local.application_name}-centralised-endpoints"
  description = "Security group for centralised interface endpoints"
  vpc_id      = module.vpc_centralised_endpoints.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-centralised-endpoints"
    }
  )
}

resource "aws_security_group_rule" "centralised_endpoint_interface_ingress" {
  description       = "Allow TLS traffic from internal RFC1918 space"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.centralised_endpoint_interface.id
}

resource "aws_vpc_endpoint" "centralised_interface_endpoints" {
  for_each = local.centralised_interface_endpoint_services

  vpc_id              = module.vpc_centralised_endpoints.vpc_id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = false
  subnet_ids          = module.vpc_centralised_endpoints.non_tgw_subnet_ids_map["private"]
  security_group_ids  = [aws_security_group.centralised_endpoint_interface.id]

  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-${each.key}-centralised-endpoint"
    }
  )
}

resource "aws_ram_resource_share" "centralised_vpc_endpoints" {
  name                      = "centralised-vpc-endpoints"
  allow_external_principals = false

  tags = local.tags
}

resource "aws_ram_resource_association" "centralised_vpc_endpoints" {
  for_each = aws_vpc_endpoint.centralised_interface_endpoints

  resource_arn       = each.value.arn
  resource_share_arn = aws_ram_resource_share.centralised_vpc_endpoints.arn
}

resource "aws_ram_principal_association" "centralised_vpc_endpoints" {
  for_each = local.centralised_endpoint_consumer_accounts

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.centralised_vpc_endpoints.arn
}

resource "aws_route53_zone" "centralised_endpoint_private_zones" {
  for_each = local.centralised_endpoint_service_private_dns_zones

  name = each.value

  vpc {
    vpc_id = module.vpc_centralised_endpoints.vpc_id
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.application_name}-${each.key}-centralised-endpoint"
    }
  )
}

resource "aws_route53_record" "centralised_endpoint_alias_records" {
  for_each = local.centralised_endpoint_service_private_dns_zones

  zone_id = aws_route53_zone.centralised_endpoint_private_zones[each.key].zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.centralised_interface_endpoints[each.key].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.centralised_interface_endpoints[each.key].dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53profiles_profile" "centralised_endpoint_dns_profile" {
  name = "centralised-endpoints"

  tags = local.tags
}

resource "aws_route53profiles_resource_association" "centralised_endpoint_private_zone_associations" {
  for_each = aws_route53_zone.centralised_endpoint_private_zones

  name         = "${local.application_name}-${each.key}-private-zone"
  profile_id   = aws_route53profiles_profile.centralised_endpoint_dns_profile.id
  resource_arn = each.value.arn
}

resource "aws_ram_resource_share" "centralised_endpoint_dns_profile" {
  name                      = "centralised-endpoint-dns-profile"
  allow_external_principals = false

  tags = local.tags
}

resource "aws_ram_resource_association" "centralised_endpoint_dns_profile" {
  resource_arn       = aws_route53profiles_profile.centralised_endpoint_dns_profile.arn
  resource_share_arn = aws_ram_resource_share.centralised_endpoint_dns_profile.arn
}

resource "aws_ram_principal_association" "centralised_endpoint_dns_profile" {
  for_each = local.centralised_endpoint_consumer_accounts

  principal          = each.value
  resource_share_arn = aws_ram_resource_share.centralised_endpoint_dns_profile.arn
}
