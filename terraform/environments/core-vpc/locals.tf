data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

data "aws_organizations_organization" "root_account" {}

locals {
  application_name           = "core-vpc"
  environment                = trimprefix(terraform.workspace, "${local.application_name}-")
  environment_management     = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production  = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"
  is-development = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-development"
  is-live_data   = (substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production") || (substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction")

  core_logging_bucket_arns = jsondecode(data.aws_ssm_parameter.core_logging_bucket_arns.insecure_value)

  tags = {
    business-unit = "Platforms"
    service-area  = "Hosting"
    application   = "Modernisation Platform: core-vpc"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}

# For Pilot To Implement CloudWatch Anomaly Detection For VPC Flow Logs
locals {
  laa_vpc_keys = [
    "laa-production",
    "laa-preproduction",
    "laa-test",
    "laa-development"
  ]

  laa_vpc_existing = { for k, v in module.vpc : k => v if contains(local.laa_vpc_keys, k) }
}
