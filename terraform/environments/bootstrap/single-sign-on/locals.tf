# This data sources allows us to get the Modernisation Platform account information for use elsewhere
data "aws_caller_identity" "modernisation-platform" {
}

data "aws_organizations_account" "organisation-security-account" {
  name = "organisation-security" # Replace with the name of the account
}

locals {

  account_ids = {
    detective_account = data.aws_organizations_account.organisation-security-account.id
  }

  app_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, "/-([[:alnum:]]+)$/", ""))

  env_name = replace(terraform.workspace, "${local.app_name}-", "")

  modernisation_platform_account = data.aws_caller_identity.modernisation-platform
  environment_management         = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  defname = jsondecode(file("../../../../environments/${local.app_name}.json"))

  sso_data = { for data in local.defname.environments :

    data.name => data.access

    if(data.name == local.env_name)
  }
}