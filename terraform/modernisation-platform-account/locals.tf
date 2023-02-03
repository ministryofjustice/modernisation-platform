data "aws_organizations_organization" "root_account" {}
data "aws_caller_identity" "current" {}
data "aws_iam_roles" "sso-admin-access" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

# Reflection of what is in member accounts, needed here as well so that the same code works for collaborators
resource "aws_ssm_parameter" "modernisation_platform_account_id" {
  name  = "modernisation_platform_account_id"
  type  = "SecureString"
  value = data.aws_caller_identity.current.id

  tags = local.tags
}

locals {
  root_account                 = data.aws_organizations_organization.root_account
  environment_management       = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  modernisation_platform_ou_id = local.environment_management.modernisation_platform_organisation_unit_id
  pagerduty_integration_keys   = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  root_users_with_state_access = [ # also includes the organisationsl GHA Role
    "arn:aws:iam::${local.root_account.master_account_id}:user/ModernisationPlatformOrganisationManagement",
    "arn:aws:iam::${local.root_account.master_account_id}:user/DavidElliott",
    "arn:aws:iam::${local.root_account.master_account_id}:role/ModernisationPlatformGithubActionsRole" # Role with the same permissions as ModernisationPlatformOrganisationManagement for Github OIDC
  ]

  collaborators = jsondecode(file("../../collaborators.json"))

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
