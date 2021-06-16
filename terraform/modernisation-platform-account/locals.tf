data "aws_organizations_organization" "root_account" {}
data "aws_caller_identity" "current" {}

locals {
  root_account                   = data.aws_organizations_organization.root_account
  environment_management         = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  modernisation_platform_account = local.root_account.accounts[index(local.root_account.accounts[*].email, "aws+modernisation-platform@digital.justice.gov.uk")]

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
