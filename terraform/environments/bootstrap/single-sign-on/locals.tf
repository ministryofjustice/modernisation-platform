# This data sources allows us to get the Modernisation Platform account information for use elsewhere
data "aws_caller_identity" "modernisation-platform" {
}

locals {

  app_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, "/-([[:alnum:]]+)$/", ""))

  env_name = replace(terraform.workspace, "${local.app_name}-", "")

  modernisation_platform_account = data.aws_caller_identity.modernisation-platform
  environment_management         = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  defname = jsondecode(file("../../../../environments/${local.app_name}.json"))

  sso_data = { for data in local.defname.environments :

    data.name => data.access

    if(data.name == local.env_name)
  }

  analytics_engineering_kms_keys = {
    dpr-prod = {
      account_name = "digital-prison-reporting-production"
      key_id       = "a9d617dd-1399-4116-bd2a-16ad43f710c9"
    }
    dpr-preprod = {
      account_name = "digital-prison-reporting-preproduction"
      key_id       = "7f78035f-f870-41b2-b00b-b7398cd6eb2d"
    }
  }

  analytics_engineering_kms_key_arns = [
    for kms_key in values(local.analytics_engineering_kms_keys) :
    "arn:aws:kms:eu-west-2:${local.environment_management.account_ids[kms_key.account_name]}:key/${kms_key.key_id}"
  ]

  tags = {
    business-unit = "Platforms"
    service-area  = "Hosting"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
