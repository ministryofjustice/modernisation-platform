locals {
  non_prod_path = "../../environments/non-production"
  applications = [
    for application in fileset("${local.non_prod_path}", "**") :
    jsondecode(file("${local.non_prod_path}/${application}"))
  ]
  expanded_applications = flatten([
    for application in local.applications : [
      for environment in application.environments : {
        name    = "${application.name}-${environment}"
        part_of = application.name
        tags    = application.tags
      }
    ]
  ])
}

# Create high-level organisation units
resource "aws_organizations_organizational_unit" "non-production" {
  provider  = aws.environments
  name      = "modernisation-platform-non-production"
  parent_id = local.environments_management.modernisation_platform_organisation_id
}

resource "aws_organizations_organizational_unit" "production" {
  provider  = aws.environments
  name      = "modernisation-platform-production"
  parent_id = local.environments_management.modernisation_platform_organisation_id
}

# Create sub-level organisation units per application
resource "aws_organizations_organizational_unit" "non-production-unit" {
  provider  = aws.environments
  parent_id = aws_organizations_organizational_unit.non-production.id
  for_each = {
    for application in local.applications :
    application.name => application
  }
  name = "modernisation-platform-${each.value.name}"
}

# Create accounts for applications and their environments, within the application organisation unit
resource "aws_organizations_account" "non-production-account" {
  provider = aws.environments
  for_each = {
    for application in local.expanded_applications :
    application.name => application
  }

  name                       = each.value.name
  email                      = "aws+mp+${each.value.name}@digital.justice.gov.uk"
  iam_user_access_to_billing = "ALLOW"
  parent_id                  = aws_organizations_organizational_unit.non-production-unit[each.value.part_of].id
  tags                       = each.value.tags
}
