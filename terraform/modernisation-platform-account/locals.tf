data "aws_organizations_organization" "root_account" {}
data "aws_regions" "current" {}
data "aws_caller_identity" "current" {}

locals {
  root_account = data.aws_organizations_organization.root_account
  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
