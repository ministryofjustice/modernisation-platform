locals {
  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: core-vpc"
    is-production = substr(terraform.workspace, length(terraform.workspace) - length("production"), length(terraform.workspace)) == "production" ? true : false
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
 }
