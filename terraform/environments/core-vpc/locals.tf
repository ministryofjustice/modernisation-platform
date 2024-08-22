data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

data "aws_organizations_organization" "root_account" {}

locals {
  application_name           = "core-vpc"
  environment_management     = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"
  is-live_data  = (substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production") || (substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction")

  # This applies the same logic as above but to determine whether the environment is the development environment. Required for firehose resources.
  is-development = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-development"
  # Determines if Firehose should be built in an environment.
  build_firehose = anytrue([local.is-development, local.is-production]) ? true : false

  # Secrets used by Firehose resources which we only require for development & production VPCs.
  xsiam = jsondecode(data.aws_secretsmanager_secret_version.xsiam_secret_arn_version.secret_string)
  cloudwatch_log_groups = local.is-production ? concat(
    [for env in module.route_53_resolver_logs : env.r53_resolver_log_name],
    [for key, value in module.vpc : value.vpc_flow_log]
  ) : []
  cloudwatch_logging_bucket = data.aws_secretsmanager_secret_version.core_logging_bucket_arn.secret_string

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: core-vpc"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}
