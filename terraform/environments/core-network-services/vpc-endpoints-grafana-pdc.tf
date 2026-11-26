locals {
  # private_dns is each service's verified private DNS name, which the
  # observability-platform tenant module's PDC agent uses. generic_dns is the
  # form in Grafana's PrivateLink guide, already deployed for explicit agent flags.
  grafana_pdc_services = {
    api = {
      service_name = "com.amazonaws.vpce.eu-west-2.vpce-svc-0b12fa07b304f0d79"
      private_dns  = "pdc-grafana-datasources-api.eu-west-2.vpce.grafana.net"
      generic_dns  = "private-datasource-connect-api.eu-west-2.vpce.grafana.net"
      port         = 443
    }
    gateway = {
      service_name = "com.amazonaws.vpce.eu-west-2.vpce-svc-04a3bf37de7c4c8be"
      private_dns  = "pdc-grafana-datasources.eu-west-2.vpce.grafana.net"
      generic_dns  = "private-datasource-connect.eu-west-2.vpce.grafana.net"
      port         = 22
    }
  }

  # Generic names keep the original service keys so their deployed zones,
  # records and Profile associations are not replaced.
  grafana_pdc_dns_names = merge([
    for name, service in local.grafana_pdc_services : {
      (name)             = { service = name, dns_name = service.generic_dns }
      "${name}-verified" = { service = name, dns_name = service.private_dns }
    }
  ]...)

  # Keep aligned with modernisation-platform-environments:
  # terraform/environments/cloud-platform/network/locals.tf (vpc_cidr).
  grafana_pdc_consumer_cidrs = {
    cloud-platform-development       = ["10.195.32.0/20", "100.66.0.0/16"]
    cloud-platform-preproduction     = ["10.195.16.0/20", "100.65.0.0/16"]
    cloud-platform-nonlive           = ["10.195.192.0/20", "100.67.0.0/16"]
    cloud-platform-live              = ["10.195.0.0/20", "100.64.0.0/16"]
    container-platform-octo-nonlive  = ["10.195.48.0/20", "100.68.0.0/16"]
    container-platform-octo-live     = ["10.41.0.0/20", "100.80.0.0/16"]
    container-platform-laa-nonlive   = ["10.195.80.0/20", "100.70.0.0/16"]
    container-platform-laa-live      = ["10.41.32.0/20", "100.82.0.0/16"]
    container-platform-hmpps-nonlive = ["10.195.64.0/20", "100.69.0.0/16"]
    container-platform-hmpps-live    = ["10.41.16.0/20", "100.81.0.0/16"]
    container-platform-cd-nonlive    = ["10.195.96.0/20", "100.71.0.0/16"]
    container-platform-cd-live       = ["10.41.48.0/20", "100.83.0.0/16"]
  }

  grafana_pdc_subnet_ids = {
    for name, service in local.grafana_pdc_services : name => [
      for az, subnet_id in module.vpc_centralised_endpoints.private_subnet_ids_by_az : subnet_id
      if contains(data.aws_vpc_endpoint_service.grafana_pdc[name].availability_zones, az)
    ]
  }

  # Exact aggregates of the twelve secondary pod CIDRs, not all of 100.64.0.0/10.
  # Aggregating keeps the private NACL within its default rule quota.
  grafana_pdc_pod_cidr_ranges = ["100.64.0.0/13", "100.80.0.0/14"]
  grafana_pdc_pod_ingress_rules = {
    for rule in flatten([
      for index, cidr in local.grafana_pdc_pod_cidr_ranges : [
        for name, service in local.grafana_pdc_services : {
          key         = "${name}-${cidr}"
          cidr        = cidr
          port        = service.port
          rule_number = 4300 + index * 10 + (name == "api" ? 0 : 1)
        }
      ]
    ]) : rule.key => rule
  }
}

# Discover AZ names in core-network-services, not in a consumer or partner account.
data "aws_vpc_endpoint_service" "grafana_pdc" {
  for_each = local.grafana_pdc_services

  service_name = each.value.service_name
}

resource "aws_security_group" "grafana_pdc" {
  for_each = local.grafana_pdc_services

  name        = "${local.application_name}-grafana-pdc-${each.key}"
  description = "Grafana PDC ${each.key} endpoint access from CP3 VPCs"
  vpc_id      = module.vpc_centralised_endpoints.vpc_id

  tags = merge(local.tags, { Name = "${local.application_name}-grafana-pdc-${each.key}" })
}

resource "aws_security_group_rule" "grafana_pdc_ingress" {
  for_each = local.grafana_pdc_services

  description       = "Allow CP3 VPC and pod traffic to the Grafana PDC ${each.key}"
  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  cidr_blocks       = flatten(values(local.grafana_pdc_consumer_cidrs))
  security_group_id = aws_security_group.grafana_pdc[each.key].id

  lifecycle {
    precondition {
      condition     = toset(keys(local.grafana_pdc_consumer_cidrs)) == toset(keys(local.centralised_endpoint_consumer_accounts))
      error_message = "Grafana PDC CIDRs must cover exactly the CP3 accounts sharing the centralised endpoint Profile, including live."
    }
  }
}

resource "aws_vpc_endpoint" "grafana_pdc" {
  for_each = local.grafana_pdc_services

  vpc_id             = module.vpc_centralised_endpoints.vpc_id
  service_name       = each.value.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.grafana_pdc_subnet_ids[each.key]
  security_group_ids = [aws_security_group.grafana_pdc[each.key].id]

  # The explicit PHZs below serve both the hub and its shared Profile consumers.
  private_dns_enabled = false

  lifecycle {
    precondition {
      condition     = length(local.grafana_pdc_subnet_ids[each.key]) > 0
      error_message = "Grafana PDC ${each.key} exposes no supported AZ containing a hub private subnet."
    }
  }

  tags = merge(local.tags, { Name = "${local.application_name}-grafana-pdc-${each.key}" })
}

resource "aws_route53_zone" "grafana_pdc" {
  for_each = local.grafana_pdc_dns_names

  name = each.value.dns_name

  vpc {
    vpc_id = module.vpc_centralised_endpoints.vpc_id
  }

  tags = merge(local.tags, { Name = "${local.application_name}-grafana-pdc-${each.key}" })
}

resource "aws_route53_record" "grafana_pdc" {
  for_each = local.grafana_pdc_dns_names

  zone_id = aws_route53_zone.grafana_pdc[each.key].zone_id
  name    = each.value.dns_name
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.grafana_pdc[each.value.service].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.grafana_pdc[each.value.service].dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53profiles_resource_association" "grafana_pdc" {
  for_each = local.grafana_pdc_dns_names

  name         = "${local.application_name}-grafana-pdc-${each.key}"
  profile_id   = aws_route53profiles_profile.centralised_endpoint_dns_profile.id
  resource_arn = aws_route53_zone.grafana_pdc[each.key].arn

  depends_on = [aws_route53_record.grafana_pdc]
}

# Primary VPC CIDRs already pass the hub NACL's RFC1918 rules. Un-SNATed pods
# also need these inbound ports and the stateless NACL's ephemeral return path.
resource "aws_network_acl_rule" "grafana_pdc_pod_ingress" {
  for_each = local.grafana_pdc_pod_ingress_rules

  network_acl_id = module.vpc_centralised_endpoints.network_acls["private"].id
  rule_number    = each.value.rule_number
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.value.cidr
  from_port      = each.value.port
  to_port        = each.value.port
}

resource "aws_network_acl_rule" "grafana_pdc_pod_return" {
  for_each = { for index, cidr in local.grafana_pdc_pod_cidr_ranges : cidr => index }

  network_acl_id = module.vpc_centralised_endpoints.network_acls["private"].id
  rule_number    = 4300 + each.value * 10
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = each.key
  from_port      = 1024
  to_port        = 65535
}
