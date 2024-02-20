# This data sources allows us to get the Modernisation Platform account information for use elsewhere
# (when we want to assume a role in the MP, for instance)
data "aws_organizations_organization" "root_account" {}
data "aws_caller_identity" "current" {}
data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

data "aws_iam_session_context" "whoami" {
  arn = data.aws_caller_identity.current.arn
}
# to allow member account AdministratorAccessRole to do local plans/applies in modernisation-platform-environments repo
data "aws_iam_roles" "member-sso-admin-access" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "http" "environments_file" {
  url = format("https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/%s.json", local.application_name)
}

locals {
  root_account                   = data.aws_organizations_organization.root_account
  modernisation_platform_account = data.aws_caller_identity.modernisation-platform
  environment_management         = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  application_name               = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, "/-([[:alnum:]]+)$/", ""))
  application_tags               = jsondecode(data.http.environments_file.response_body).tags
  business_unit                  = local.application_tags.business-unit
  application_environment        = length(regexall("^bichard*.|^remote-supervisio*.", terraform.workspace)) > 0 ? terraform.workspace : substr(terraform.workspace, length(local.application_name) + 1, -1)
  environments_list = {
    for file in fileset("../../../../environments", "*.json") :
    replace(file, ".json", "") => jsondecode(file("../../../../environments/${file}"))
  }

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: Member Bootstrap"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
    component     = "member-bootstrap"
    source-code   = "https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/environments/bootstrap/member-bootstrap"
  }

  # When a new account has been added, the organisation-security Terraform must be run before an environment is added here
  ssm_resource_sync_opt_in = [
    "ccms-ebs-development",
    "ccms-ebs-test",
    "ccms-ebs-preproduction",
    "ccms-ebs-production",
    "example-development",
    "oasys-development",
    "oasys-test",
    "oasys-preproduction",
    "oasys-production"
  ]

  # skip the following alias creation if the alias is used by another account (they are globally unique)
  skip_alias = sort([
    "apex-development",
    "apex-production",
    "apex-test",
    "data-platform-production",
    "eric-test",
    "eric-production",
    "nomis-production",
    "testing-test",
    "nomis-development",
    "oas-test",
    "portal-development",
    "portal-production",
    "portal-test"
  ])
}