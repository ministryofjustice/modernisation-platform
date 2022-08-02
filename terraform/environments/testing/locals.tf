# This data sources allows us to get the Modernisation Platform account information for use elsewhere
# (when we want to assume a role in the MP, for instance)
data "aws_organizations_organization" "root_account" {}

# Get the current account id
data "aws_caller_identity" "testing_test" {}
# Get modernisation plaftorm account ID
data "aws_caller_identity" "modernisation_platform" {
  provider = aws.modernisation-platform
}

# Get the environments file from the main repository
data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.application_name}.json"
}

# Get the state S3 bucket, dynamodb and environment keys
data "aws_kms_key" "s3_state_bucket" {
  provider = aws.modernisation-platform
  key_id   = "alias/s3-state-bucket"
}
data "aws_kms_key" "dynamodb_state_lock" {
  provider = aws.modernisation-platform
  key_id   = "alias/dynamodb-state-lock"
}
data "aws_kms_key" "environment_management" {
  provider = aws.modernisation-platform
  key_id   = "alias/environment-management"
}
data "aws_kms_key" "pagerduty" {
  provider = aws.modernisation-platform
  key_id   = "alias/pagerduty-secret"
}

locals {

  application_name = "testing"

  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production    = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"
  is-preproduction = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction"
  is-test          = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-test"
  is-development   = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-development"

  # Merge tags from the environment json file with additional ones
  tags = merge(
    jsondecode(data.http.environments_file.response_body).tags,
    { "is-production" = local.is-production },
    { "environment-name" = terraform.workspace },
    { "source-code" = "https://github.com/ministryofjustice/modernisation-platform" }
  )

  environment = trimprefix(terraform.workspace, "${var.networking[0].application}-")
  vpc_name    = var.networking[0].business-unit
  subnet_set  = var.networking[0].set

  is_live       = [substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production" || substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction" ? "live" : "non-live"]
  provider_name = "core-vpc-${local.environment}"

}
