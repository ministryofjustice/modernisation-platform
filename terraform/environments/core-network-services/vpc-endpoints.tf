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

  # gateway = "none" to avoid a circular Terraform dependency: the vpc-hub
  # module does not create a TGW attachment, so setting gateway = "transit"
  # causes route creation to fail (AWS requires the attachment to exist first).
  # Return-path routes (0.0.0.0/0 → TGW) are created explicitly below, after
  # the TGW attachment is provisioned, using the attachment ID as an implicit
  # dependency signal to Terraform.
  gateway = "none"

  # VPC Flow Logs
  vpc_flow_log_iam_role       = aws_iam_role.vpc_flow_log.arn
  flow_log_s3_destination_arn = local.core_logging_bucket_arns["vpc-flow-logs"]

  # Transit Gateway ID
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  # Tags
  tags_common = local.tags
  tags_prefix = "centralised-endpoints"
}

# TGW attachment for the centralised endpoint hub VPC.
# Disables default route table association/propagation — we manage these explicitly.
resource "aws_ec2_transit_gateway_vpc_attachment" "centralised_endpoints" {
  transit_gateway_id                              = aws_ec2_transit_gateway.transit-gateway.id
  vpc_id                                          = module.vpc_centralised_endpoints.vpc_id
  subnet_ids                                      = module.vpc_centralised_endpoints.tgw_subnet_ids
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    local.tags,
    { Name = "centralised-endpoints-attachment" }
  )
}

# Return-path default routes (0.0.0.0/0 → TGW) on all private and data route
# tables in the hub VPC. Referencing the attachment's transit_gateway_id
# attribute creates an implicit Terraform dependency, ensuring the attachment
# exists before these routes are applied.
resource "aws_route" "centralised_endpoints_private_tgw" {
  for_each = module.vpc_centralised_endpoints.private_route_tables_map["private"]

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.centralised_endpoints.transit_gateway_id
}

resource "aws_route" "centralised_endpoints_data_tgw" {
  for_each = module.vpc_centralised_endpoints.private_route_tables_map["data"]

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.centralised_endpoints.transit_gateway_id
}

resource "aws_route" "centralised_endpoints_transit_gateway_tgw" {
  for_each = module.vpc_centralised_endpoints.private_route_tables_map["transit_gateway"]

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.centralised_endpoints.transit_gateway_id
}

# Dedicated TGW route table for the hub attachment.
resource "aws_ec2_transit_gateway_route_table" "centralised_endpoints" {
  transit_gateway_id = aws_ec2_transit_gateway.transit-gateway.id

  tags = merge(local.tags, { Name = "centralised_endpoints" })
}

# Associate the hub attachment with its dedicated TGW route table.
resource "aws_ec2_transit_gateway_route_table_association" "centralised_endpoints" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.centralised_endpoints.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.centralised_endpoints.id
}

# Propagate live and non-live MP consumer VPC attachments into the hub's TGW
# route table so return traffic from endpoint ENIs can reach consumer VPCs.
resource "aws_ec2_transit_gateway_route_table_propagation" "centralised_endpoints_from_live" {
  for_each = local.tgw_live_data_attachments

  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.centralised_endpoints.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "centralised_endpoints_from_non_live" {
  for_each = local.tgw_non_live_data_attachments

  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.centralised_endpoints.id
}

# Static routes in live_data and non_live_data TGW route tables pointing the
# hub VPC CIDR to the centralised endpoints attachment. This enables consumer
# VPCs to reach the endpoint ENIs.
resource "aws_ec2_transit_gateway_route" "centralised_endpoints_live_data" {
  destination_cidr_block         = local.centralised_endpoint_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.centralised_endpoints.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["live_data"].id
}

resource "aws_ec2_transit_gateway_route" "centralised_endpoints_non_live_data" {
  destination_cidr_block         = local.centralised_endpoint_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.centralised_endpoints.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.route-tables["non_live_data"].id
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
