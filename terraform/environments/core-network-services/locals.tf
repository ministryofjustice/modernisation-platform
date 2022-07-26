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

  live_tgw_vpc_attachments = [
    "core-logging-live_data-attachment",
    "core-network-services-live_data-attachment",
    "core-security-live_data-attachment",
    "core-shared-services-live_data-attachment",
    "hmcts-preproduction-attachment",
    "hmcts-production-attachment",
    "hmpps-preproduction-attachment",
    "hmpps-production-attachment",
    "hq-production-attachment"
  ]

  non_live_tgw_vpc_attachments = [
    "cica-development-attachment",
    "core-logging-non_live_data-attachment",
    "core-network-services-non_live_data-attachment",
    "core-security-non_live_data-attachment",
    "core-shared-services-non_live_data-attachment",
    "garden-sandbox-attachment",
    "hmcts-development-attachment",
    "hmpps-development-attachment",
    "hmpps-test-attachment",
    "house-sandbox-attachment",
    "hq-development-attachment",
    "platforms-development-attachment",
    "platforms-test-attachment"
  ]
}
