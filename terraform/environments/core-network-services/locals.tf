data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

data "aws_organizations_organization" "root_account" {}

locals {
  application_name           = "core-network-services"
  environment_management     = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: core-network-services"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

  active_tgw_peering_attachments = [
    "PTTP-Transit-Gateway-attachment-accepter"
  ]

  active_tgw_vpc_attachments = [
    "hmcts-production-attachment",
    "hmpps-production-attachment",
    "core-network-services-live_data-attachment",
  ]

  development_rules     = fileexists("./firewall-rules/development_rules.json") ? jsondecode(templatefile("./firewall-rules/development_rules.json", local.all_cidr_ranges)) : {}
  test_rules            = fileexists("./firewall-rules/test_rules.json") ? jsondecode(templatefile("./firewall-rules/test_rules.json", local.all_cidr_ranges)) : {}
  preproduction_rules   = fileexists("./firewall-rules/preproduction_rules.json") ? jsondecode(templatefile("./firewall-rules/preproduction_rules.json", local.all_cidr_ranges)) : {}
  production_rules      = fileexists("./firewall-rules/production_rules.json") ? jsondecode(templatefile("./firewall-rules/production_rules.json", local.all_cidr_ranges)) : {}
  fqdn_firewall_rules   = fileexists("./firewall-rules/fqdn_rules.json") ? jsondecode(file("./firewall-rules/fqdn_rules.json")) : {}
  inline_firewall_rules = fileexists("./firewall-rules/inline_rules.json") ? jsondecode(templatefile("./firewall-rules/inline_rules.json", local.all_cidr_ranges)) : {}
  firewall_rules        = merge(local.development_rules, local.test_rules, local.preproduction_rules, local.production_rules)

  vpn_attachments = fileexists("./vpn_attachments.json") ? jsondecode(file("./vpn_attachments.json")) : {}

  noms_vpn_attachment_ids = toset([for k in aws_vpn_connection.this : k.transit_gateway_attachment_id if(length(regexall("(?:NOMS)", k.tags.Name)) > 0)])

  azure_static_routes = [
    "10.0.0.0/11",
    "10.64.0.0/11",
    "10.100.0.0/15",
    "10.104.0.0/16",
    "10.108.0.0/18",
    "10.108.64.0/23",
    "10.128.0.0/16",
    "10.132.0.0/16",
    "10.136.0.0/13",
    "10.147.0.0/16",
    "10.148.0.0/14",
    "10.154.0.0/23",
    "10.154.16.0/23",
    "10.154.32.0/23",
    "10.154.64.0/23",
    "10.154.96.0/23",
    "10.154.112.0/23",
    "10.154.128.0/23",
    "10.154.144.0/23",
    "10.154.160.0/23",
    "10.154.192.0/23",
    "10.159.240.0/20",
    "10.163.0.0/20",
    "10.171.0.0/16",
    "10.172.0.0/16",
    "10.175.0.0/16",
    "10.176.0.0/16",
    "10.178.0.0/16",
    "10.179.0.0/16",
    "10.188.0.160/27",
    "10.205.0.0/24",
    "10.208.0.0/12",
    "10.211.0.0/22",
    "10.228.224.0/19",
    "10.231.252.0/23",
    "10.232.0.0/16",
    "10.233.64.0/18",
    "10.233.128.0/18",
    "10.233.192.0/20",
    "10.233.208.0/22",
    "10.233.212.0/23",
    "10.233.214.0/23",
    "10.233.216.0/21",
    "10.233.224.0/19",
    "10.234.0.0/15",
    "10.236.0.0/14",
    "10.240.0.0/16",
    "10.243.224.0/20",
    "10.245.252.0/22",
    "172.16.0.0/12",
    "172.16.9.0/24",
    "172.16.10.0/24",
    "172.17.0.0/16",
    "172.18.0.0/15",
    "172.20.0.0/15",
    "172.22.0.0/15",
    "172.25.181.0/24",
    "195.59.116.244/32"
  ]

  parole_board_vpn_static_routes = ["10.50.0.0/16"]

  core-vpcs = {
    for file in fileset("../../../environments-networks", "*.json") :
    replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
  }

}
