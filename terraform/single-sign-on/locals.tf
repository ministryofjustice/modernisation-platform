locals {
  sso_instance_arn       = coalesce(data.aws_ssoadmin_instances.default.arns...)
  sso_identity_store_id  = coalesce(data.aws_ssoadmin_instances.default.identity_store_ids...)
  sso_admin_instance_arn = coalesce(data.aws_ssoadmin_instances.default.arns...)
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  tags = {
    business-unit = "Platforms"
    service-area  = "Hosting"
    application   = "Modernisation Platform"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

}
