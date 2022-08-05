# This data sources allows us to get the Modernisation Platform account information for use elsewhere
# (when we want to assume a role in the MP, for instance)
data "aws_organizations_organization" "root_account" {}

locals {
  root_account                   = data.aws_organizations_organization.root_account
  modernisation_platform_account = local.root_account.accounts[index(local.root_account.accounts[*].email, "aws+modernisation-platform@digital.justice.gov.uk")]
  environment_management         = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  environments = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: Environments Management"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
    component     = "delegate-access"
    source-code   = "https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/environments/bootstrap/delegate-access"
  }
  # skip the following alias creation if the alias is used by another account (they are globally unique)
  skip_alias = sort([
    "apex-development",
    "nomis-production",
    "testing-test"
  ])
}