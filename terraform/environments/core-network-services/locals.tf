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
  inline_fqdn_rules     = fileexists("./firewall-rules/inline_fqdn_rules.json") ? jsondecode(file("./firewall-rules/inline_fqdn_rules.json")) : {}
  firewall_rules        = merge(local.development_rules, local.test_rules, local.preproduction_rules, local.production_rules)

  vpn_attachments = fileexists("./vpn_attachments.json") ? jsondecode(file("./vpn_attachments.json")) : {}

  noms_dr_vpn_static_routes = [
    "10.40.64.0/18",
    "10.40.144.0/20",
    "10.40.176.0/20",
    "10.111.0.0/16",
    "10.112.0.0/16",
    "10.244.0.0/20",
    "10.247.0.0/20"
  ]
  noms_live_vpn_static_routes = [
    "10.40.0.0/18",
    "10.40.128.0/20",
    "10.40.160.0/20",
    "10.101.0.0/16",
    "10.102.0.0/16",
    "10.47.0.0/26",
    "10.47.0.64/26",
    "10.47.0.128/26"
  ]

  parole_board_vpn_static_routes = ["10.50.0.0/16"]

  core-vpcs = {
    for file in fileset("../../../environments-networks", "*.json") :
    replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
  }
}
