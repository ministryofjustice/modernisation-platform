# This data sources allows us to get the Modernisation Platform account information for use elsewhere
data "aws_caller_identity" "modernisation-platform" {
}
data "aws_secretsmanager_secret_version" "organisation_security_id" {
  provider  = aws.modernisation-secrets-read
  secret_id = "organisation_security_id" # Name of the secret in AWS Secrets Manager
}
locals {

  organisation_security_account_id = jsondecode(data.aws_secretsmanager_secret_version.organisation_security_id.secret_string)["organisation_security_id"]

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