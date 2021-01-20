# This data sources allows us to get the Modernisation Platform account information for use elsewhere
# (when we want to assume a role in the MP, for instance)
data "aws_organizations_organization" "root_account" {}

locals {
  root_account                   = data.aws_organizations_organization.root_account
  modernisation_platform_account = local.root_account.accounts[index(local.root_account.accounts[*].email, "aws+modernisation-platform@digital.justice.gov.uk")]
  environment_management         = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
}
