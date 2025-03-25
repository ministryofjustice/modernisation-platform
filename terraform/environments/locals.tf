# This data sources allows us to get the Modernisation Platform account information for use elsewhere
# (when we want to assume a role in the MP, for instance)
data "aws_organizations_organization" "root_account" {}

data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.root_account.roots[0].id
}

data "aws_organizations_organizational_units" "platforms_architecture" {
  parent_id = join("", [for ou in data.aws_organizations_organizational_units.root_ous.children : ou.id if ou.name == "Platforms & Architecture"])
}

data "aws_organizations_accounts" "organisation_security_accounts" {
  parent_id = join("", [for ou in data.aws_organizations_organizational_units.organisation_security_ou.children : ou.id if ou.name == "Organisation Security"])
}

data "aws_caller_identity" "current" {}

locals {
  environments = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: Environments Management"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
  root_account                     = data.aws_organizations_organization.root_account
  organisation_security_account_id = join("", [for account in data.aws_organizations_accounts.organisation_security_accounts.accounts : account.id if account.name == "Organisation Security Account"])
  modernisation_platform_account   = local.root_account.accounts[index(local.root_account.accounts[*].email, "aws+modernisation-platform@digital.justice.gov.uk")]
  github_repository                = "github.com:ministryofjustice/modernisation-platform.git"
  modernisation_platform_ou_id     = join("", [for ou in data.aws_organizations_organizational_units.platforms_architecture.children : ou.id if ou.name == "Modernisation Platform"])
}
