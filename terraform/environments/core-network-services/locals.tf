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
  
  active_tgw_all_attachments = [
    "cjse-production-attachment",
    "hmcts-test-attachment",
    "cjse-development-attachment",
    "laa-preproduction-attachment",
    "core-logging-live_data-attachment",
    "core-shared-services-non_live_data-attachment",
    "core-shared-services-live_data-attachment",
    "hmpps-development-attachment",
    "hmpps-test-attachment",
    "opg-test-attachment",
    "hq-production-attachment",
    "opg-development-attachment",
    "laa-test-attachment",
    "platforms-development-attachment",
    "laa-production-attachment",
    "core-security-non_live_data-attachment",
    "opg-production-attachment",
    "hmcts-development-attachment",
    "cica-production-attachment",
    "cjse-test-attachment",
    "core-logging-non_live_data-attachment",
    "inspection-attachment",
    "cjse-preproduction-attachment",
    "platforms-test-attachment",
    "platforms-preproduction-attachment",
    "platforms-production-attachment",
    "core-security-live_data-attachment",
    "cica-development-attachment",
    "opg-preproduction-attachment",
    "core-network-services-non_live_data-attachment",
    "hq-test-attachment",
    "cica-preproduction-attachment",
    "house-sandbox-attachment",
    "hmcts-preproduction-attachment",
    "hmcts-production-attachment",
    "laa-development-attachment",
    "hq-development-attachment",
    "hq-preproduction-attachment",
    "garden-sandbox-attachment",
    "cica-test-attachment"

  ]

  development_rules   = fileexists("./development_rules.json") ? jsondecode(file("./development_rules.json")) : {}
  test_rules          = fileexists("./test_rules.json") ? jsondecode(file("./test_rules.json")) : {}
  preproduction_rules = fileexists("./preproduction_rules.json") ? jsondecode(file("./preproduction_rules.json")) : {}
  production_rules    = fileexists("./production_rules.json") ? jsondecode(file("./production_rules.json")) : {}
  firewall_rules      = merge(local.development_rules, local.test_rules, local.preproduction_rules, local.production_rules)

  vpn_attachments = fileexists("./vpn_attachments.json") ? jsondecode(file("./vpn_attachments.json")) : {}
  noms_vpn_static_routes = [
    "10.40.64.0/18",
    "10.40.144.0/20",
    "10.40.176.0/20",
    "10.111.0.0/16",
    "10.112.0.0/16"
  ]

  core-vpcs = {
    for file in fileset("../../../environments-networks", "*.json") :
    replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
  }
}
