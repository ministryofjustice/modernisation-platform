# Targeted mocked plans exercise the real hub configuration without AWS access.
# Run with TF_WORKSPACE=core-network-services-production terraform test
#   -filter=tests/grafana-pdc.tftest.hcl
mock_provider "aws" {
  override_during = plan

  mock_data "aws_region" {
    defaults = { region = "eu-west-2" }
  }

  mock_data "aws_vpc_endpoint_service" {
    defaults = { availability_zones = ["eu-west-2a", "eu-west-2b"] }
  }

  mock_resource "aws_security_group" {
    defaults = { id = "sg-00000000000000003" }
  }

  mock_resource "aws_route53profiles_profile" {
    defaults = { id = "rp-00000000000000001" }
  }
}

mock_provider "aws" {
  alias = "modernisation-platform"
}

mock_provider "aws" {
  alias = "modernisation-secrets-read"
}

mock_provider "aws" {
  alias = "core-eu-west-1"
}

mock_provider "aws" {
  alias = "aws-us-east-1"
}

mock_provider "time" {}
mock_provider "random" {}
mock_provider "tls" {}

override_data {
  target = data.aws_secretsmanager_secret_version.environment_management
  values = {
    secret_string = <<-JSON
      {"account_ids": {
        "cloud-platform-development": "111111111111",
        "cloud-platform-preproduction": "111111111111",
        "cloud-platform-nonlive": "111111111111",
        "cloud-platform-live": "111111111111",
        "container-platform-cd-nonlive": "111111111111",
        "container-platform-cd-live": "111111111111",
        "container-platform-hmpps-nonlive": "111111111111",
        "container-platform-hmpps-live": "111111111111",
        "container-platform-laa-nonlive": "111111111111",
        "container-platform-laa-live": "111111111111",
        "container-platform-octo-nonlive": "111111111111",
        "container-platform-octo-live": "111111111111"
      }}
    JSON
  }
}

override_module {
  target = module.vpc_centralised_endpoints
  outputs = {
    vpc_id = "vpc-00000000000000001"
    private_subnet_ids_by_az = {
      eu-west-2a = "subnet-00000000000000001"
      eu-west-2b = "subnet-00000000000000002"
      eu-west-2c = "subnet-00000000000000003"
    }
    non_tgw_subnet_ids_map = {
      private = ["subnet-00000000000000001", "subnet-00000000000000002", "subnet-00000000000000003"]
    }
    network_acls = { private = { id = "acl-00000000000000001" } }
  }
}

override_resource {
  target          = aws_route53_zone.grafana_pdc["api"]
  override_during = plan
  values = {
    zone_id = "ZPRIVATEAPI"
    arn     = "arn:aws:route53:::hostedzone/ZPRIVATEAPI"
  }
}

override_resource {
  target          = aws_route53_zone.grafana_pdc["gateway"]
  override_during = plan
  values = {
    zone_id = "ZPRIVATEGATEWAY"
    arn     = "arn:aws:route53:::hostedzone/ZPRIVATEGATEWAY"
  }
}

override_resource {
  target          = aws_security_group.grafana_pdc["api"]
  override_during = plan
  values          = { id = "sg-00000000000000001" }
}

override_resource {
  target          = aws_security_group.grafana_pdc["gateway"]
  override_during = plan
  values          = { id = "sg-00000000000000002" }
}

override_resource {
  target          = aws_vpc_endpoint.grafana_pdc["api"]
  override_during = plan
  values = {
    dns_entry = [{
      dns_name       = "vpce-api.vpce-svc-api.eu-west-2.vpce.amazonaws.com"
      hosted_zone_id = "ZAPI"
    }]
  }
}

override_resource {
  target          = aws_vpc_endpoint.grafana_pdc["gateway"]
  override_during = plan
  values = {
    dns_entry = [{
      dns_name       = "vpce-gateway.vpce-svc-gateway.eu-west-2.vpce.amazonaws.com"
      hosted_zone_id = "ZGATEWAY"
    }]
  }
}

run "shared_endpoints" {
  command = plan

  plan_options {
    target = [
      aws_vpc_endpoint.grafana_pdc,
      aws_security_group_rule.grafana_pdc_ingress,
      aws_route53_record.grafana_pdc,
      aws_route53profiles_resource_association.grafana_pdc,
      aws_network_acl_rule.grafana_pdc_pod_ingress,
      aws_network_acl_rule.grafana_pdc_pod_return,
      aws_vpc_endpoint.centralised_interface_endpoints,
      aws_security_group_rule.centralised_endpoint_interface_ingress,
    ]
  }

  override_data {
    target = data.aws_vpc_endpoint_service.grafana_pdc["api"]
    values = { availability_zones = ["eu-west-2a", "eu-west-2c"] }
  }

  override_data {
    target = data.aws_vpc_endpoint_service.grafana_pdc["gateway"]
    values = { availability_zones = ["eu-west-2b"] }
  }

  assert {
    condition = (
      aws_vpc_endpoint.grafana_pdc["api"].subnet_ids == toset(["subnet-00000000000000001", "subnet-00000000000000003"]) &&
      aws_vpc_endpoint.grafana_pdc["gateway"].subnet_ids == toset(["subnet-00000000000000002"])
    )
    error_message = "Each partner endpoint must use only the hub subnets in its own supported AZs."
  }

  assert {
    condition = (
      length(aws_vpc_endpoint.grafana_pdc) == 2 &&
      alltrue([for name, endpoint in aws_vpc_endpoint.grafana_pdc :
        endpoint.vpc_id == module.vpc_centralised_endpoints.vpc_id &&
        endpoint.vpc_endpoint_type == "Interface" &&
        endpoint.service_name == data.aws_vpc_endpoint_service.grafana_pdc[name].service_name &&
        endpoint.security_group_ids == toset([aws_security_group.grafana_pdc[name].id]) &&
        !endpoint.private_dns_enabled
      ]) &&
      aws_security_group.grafana_pdc["api"].id != aws_security_group.grafana_pdc["gateway"].id
    )
    error_message = "There must be two hub partner endpoints, each with its own security group and explicit PHZ DNS."
  }

  assert {
    condition = (
      aws_security_group_rule.grafana_pdc_ingress["api"].from_port == 443 &&
      aws_security_group_rule.grafana_pdc_ingress["api"].to_port == 443 &&
      aws_security_group_rule.grafana_pdc_ingress["gateway"].from_port == 22 &&
      aws_security_group_rule.grafana_pdc_ingress["gateway"].to_port == 22 &&
      alltrue([for name, rule in aws_security_group_rule.grafana_pdc_ingress :
        rule.type == "ingress" && rule.protocol == "tcp" &&
        rule.security_group_id == aws_security_group.grafana_pdc[name].id &&
        toset(rule.cidr_blocks) == toset(flatten(values(local.grafana_pdc_consumer_cidrs))) &&
        length(rule.cidr_blocks) == 24
      ]) &&
      toset(keys(local.grafana_pdc_consumer_cidrs)) == toset(keys(local.centralised_endpoint_consumer_accounts))
    )
    error_message = "Both primary and pod CIDRs of all twelve CP3 VPCs, including live, must have only the endpoint's own TCP port."
  }

  assert {
    condition = alltrue([for name, service in local.grafana_pdc_services :
      aws_route53_zone.grafana_pdc[name].name == service.private_dns &&
      one(aws_route53_zone.grafana_pdc[name].vpc).vpc_id == module.vpc_centralised_endpoints.vpc_id &&
      aws_route53_record.grafana_pdc[name].name == service.private_dns &&
      aws_route53_record.grafana_pdc[name].type == "A" &&
      aws_route53_record.grafana_pdc[name].zone_id == aws_route53_zone.grafana_pdc[name].zone_id &&
      one(aws_route53_record.grafana_pdc[name].alias).name == aws_vpc_endpoint.grafana_pdc[name].dns_entry[0].dns_name &&
      one(aws_route53_record.grafana_pdc[name].alias).zone_id == aws_vpc_endpoint.grafana_pdc[name].dns_entry[0].hosted_zone_id &&
      !one(aws_route53_record.grafana_pdc[name].alias).evaluate_target_health &&
      aws_route53profiles_resource_association.grafana_pdc[name].profile_id == aws_route53profiles_profile.centralised_endpoint_dns_profile.id &&
      aws_route53profiles_resource_association.grafana_pdc[name].resource_arn == aws_route53_zone.grafana_pdc[name].arn
    ])
    error_message = "Each private name must alias its own endpoint and be shared through the existing Profile."
  }

  assert {
    condition = (
      length(aws_network_acl_rule.grafana_pdc_pod_ingress) == 4 &&
      length(aws_network_acl_rule.grafana_pdc_pod_return) == 2 &&
      alltrue([for rule in aws_network_acl_rule.grafana_pdc_pod_ingress :
        !rule.egress && rule.protocol == "tcp" && rule.rule_action == "allow" &&
        rule.network_acl_id == module.vpc_centralised_endpoints.network_acls["private"].id &&
        contains([22, 443], rule.from_port) && rule.to_port == rule.from_port &&
        contains(["100.64.0.0/13", "100.80.0.0/14"], rule.cidr_block)
      ]) &&
      alltrue([for rule in aws_network_acl_rule.grafana_pdc_pod_return :
        rule.egress && rule.protocol == "tcp" && rule.rule_action == "allow" &&
        rule.network_acl_id == module.vpc_centralised_endpoints.network_acls["private"].id &&
        rule.from_port == 1024 && rule.to_port == 65535 &&
        contains(["100.64.0.0/13", "100.80.0.0/14"], rule.cidr_block)
      ])
    )
    error_message = "Pod NACL rules must only add PDC ingress and ephemeral replies on the hub private subnets."
  }

  assert {
    condition = (
      length(aws_vpc_endpoint.centralised_interface_endpoints) == length(local.centralised_endpoint_configuration.interface_endpoint_names) &&
      alltrue([for endpoint in aws_vpc_endpoint.centralised_interface_endpoints :
        endpoint.private_dns_enabled &&
        endpoint.subnet_ids == toset(module.vpc_centralised_endpoints.non_tgw_subnet_ids_map["private"]) &&
        endpoint.security_group_ids == toset([aws_security_group.centralised_endpoint_interface.id])
      ]) &&
      aws_security_group_rule.centralised_endpoint_interface_ingress.from_port == 443 &&
      aws_security_group_rule.centralised_endpoint_interface_ingress.to_port == 443 &&
      toset(aws_security_group_rule.centralised_endpoint_interface_ingress.cidr_blocks) == toset(["10.0.0.0/8"])
    )
    error_message = "Existing AWS endpoint placement, private DNS and HTTPS-only access must remain unchanged."
  }
}

run "unsupported_api_az" {
  command = plan

  plan_options {
    target = [aws_vpc_endpoint.grafana_pdc]
  }

  override_data {
    target = data.aws_vpc_endpoint_service.grafana_pdc["api"]
    values = { availability_zones = ["eu-west-2d"] }
  }

  expect_failures = [aws_vpc_endpoint.grafana_pdc["api"]]
}

run "unsupported_gateway_az" {
  command = plan

  plan_options {
    target = [aws_vpc_endpoint.grafana_pdc]
  }

  override_data {
    target = data.aws_vpc_endpoint_service.grafana_pdc["gateway"]
    values = { availability_zones = [] }
  }

  expect_failures = [aws_vpc_endpoint.grafana_pdc["gateway"]]
}
