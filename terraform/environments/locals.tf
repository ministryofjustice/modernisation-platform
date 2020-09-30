locals {
  environments = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: Environments Management"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}

# This allows us to get the Modernisation Platform account information for use elsewhere
# (when we want to assume a role in the MP, for instance)
data "aws_organizations_organization" "root" {}
locals {
  modernisation_platform_account = data.aws_organizations_organization.root.accounts[index(data.aws_organizations_organization.root.accounts[*].email, "aws+modernisation-platform@digital.justice.gov.uk")]
}
