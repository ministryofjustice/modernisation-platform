data "aws_organizations_organization" "root_account" {}

data "aws_caller_identity" "current" {}

locals {
  application_name       = "core-shared-services"
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  root_account = data.aws_organizations_organization.root_account

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: ${terraform.workspace}"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
