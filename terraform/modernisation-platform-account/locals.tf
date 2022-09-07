data "aws_organizations_organization" "root_account" {}
data "aws_caller_identity" "current" {}

locals {
  root_account               = data.aws_organizations_organization.root_account
  environment_management     = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  modernisation_platform_ou_id = local.environment_management.modernisation_platform_organisation_unit_id
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  root_users_with_state_access = [
    "arn:aws:iam::${local.root_account.master_account_id}:user/ModernisationPlatformOrganisationManagement",
    "arn:aws:iam::${local.root_account.master_account_id}:user/DavidElliott"
  ]

  collaborators = jsondecode(file("../../collaborators.json"))

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
