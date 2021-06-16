# # There are more OUs within the Modernisation Platform Core, but they are managed elsewhere
# See: https://github.com/ministryofjustice/modernisation-platform
resource "aws_organizations_organizational_unit" "platforms-and-architecture-modernisation-platform-core" {
  name      = "Modernisation Platform Core"
  parent_id = local.environment_management.modernisation_platform_organisation_unit_id
}

# There are more OUs within the Modernisation Platform Member, but they are managed elsewhere
# See: https://github.com/ministryofjustice/modernisation-platform
resource "aws_organizations_organizational_unit" "platforms-and-architecture-modernisation-platform-member" {
  name      = "Modernisation Platform Member"
  parent_id = local.environment_management.modernisation_platform_organisation_unit_id
}

# There are more OUs within the Modernisation Platform Member Unrestricted, but they are managed elsewhere
# See: https://github.com/ministryofjustice/modernisation-platform
resource "aws_organizations_organizational_unit" "platforms-and-architecture-modernisation-platform-member-unrestricted" {
  name      = "Modernisation Platform Member Unrestricted"
  parent_id = local.environment_management.modernisation_platform_organisation_unit_id
}
