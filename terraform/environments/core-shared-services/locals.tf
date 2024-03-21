data "aws_organizations_organization" "root_account" {}

data "aws_caller_identity" "current" {}

data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

locals {
  application_name           = "core-shared-services"
  environment_management     = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  root_account = data.aws_organizations_organization.root_account

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"

  # This produces a distinct list of business units after reading all the JSON files in the environments directory
  environment_files = [
    for file in fileset("../../../environments", "*.json") :
    merge({ name = replace(file, ".json", "") }, jsondecode(file("../../../environments/${file}")))
  ]

  environment = {
    business_units = distinct([
    for member in local.environment_files : lower(member.tags.business-unit)])
    members = flatten([
      for member in local.environment_files : [
        for application in member.environments : {
          account_name  = lower(format("%s-%s", member.name, application.name))
          business_unit = lower(member.tags.business-unit)
      }]
    ])
  }

  business_units = local.environment.business_units

  business_units_with_accounts = {
    for business_unit in local.environment.business_units :
    business_unit => [
      for member in local.environment.members : member.account_name
      if member.business_unit == business_unit
    ]
  }

   # This local allows us to references the key / value pairs held in xsiam_secrets.
  xsiam = jsondecode(data.aws_secretsmanager_secret_version.xsiam_secret_arn_version.secret_string)

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: ${terraform.workspace}"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
