# This data sources allows us to get the Modernisation Platform account information for use elsewhere
# (when we want to assume a role in the MP, for instance)
data "aws_organizations_organization" "root_account" {}
data "aws_caller_identity" "current" {}
data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

# To Get Modernisation Platform Account Number
data "aws_ssm_parameter" "modernisation_platform_account_id" {
  provider = aws.modernisation-platform
  name     = "modernisation_platform_account_id"
}

data "aws_iam_session_context" "whoami" {
  arn = data.aws_caller_identity.current.arn
}
# to allow member account AdministratorAccessRole to do local plans/applies in modernisation-platform-environments repo
data "aws_iam_roles" "member-sso-admin-access" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

data "aws_iam_role" "sprinkler_oidc" {
  count = (terraform.workspace == "sprinkler-development") ? 1 : 0
  name  = "github-actions"
}

data "aws_iam_role" "sprinkler_environments_read_only" {
  count = (terraform.workspace == "sprinkler-development") ? 1 : 0
  name  = "github-actions-environments-read-only"
}

data "aws_iam_role" "sprinkler_environments_dev_test" {
  count = (terraform.workspace == "sprinkler-development") ? 1 : 0
  name  = "github-actions-environments-dev-test"
}

data "http" "environments_file" {
  url = format("https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/%s.json", local.application_name)
}

# Fetch environment-specific configuration from environments.json
data "http" "environment_definition" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.environment_file_name}.json"
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
    service-area  = "Hosting"
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
    "electronic-monitoring-data-preproduction",
    "nomis-production",
    "testing-test",
    "nomis-development",
    "oas-test",
    "vcms-test"
  ])

  # Parse workspace name to extract environment app name and lifecycle
  # Handles special cases via environment_file_overrides for non-standard naming
  workspace = terraform.workspace

  environment_file_overrides = {
    "analytical-platform-data-engineering-sandboxa" = { app = "analytical-platform-data-engineering", lifecycle = "sandbox" }
    "bichard7-sandbox-a"                            = { app = "bichard7", lifecycle = "sandbox" }
    "bichard7-sandbox-b"                            = { app = "bichard7", lifecycle = "sandbox" }
    "bichard7-sandbox-shared"                       = { app = "bichard7", lifecycle = "sandbox" }
    "bichard7-shared"                               = { app = "bichard7", lifecycle = "sandbox" }
    "bichard7-test-current"                         = { app = "bichard7", lifecycle = "test" }
    "bichard7-test-next"                            = { app = "bichard7", lifecycle = "test" }
  }

  parsed_workspace = try(
    local.environment_file_overrides[local.workspace],
    {
      app       = join("-", slice(split("-", local.workspace), 0, length(split("-", local.workspace)) - 1))
      lifecycle = element(split("-", local.workspace), length(split("-", local.workspace)) - 1)
    }
  )

  environment_file_name    = local.parsed_workspace.app
  lifecycle_from_workspace = local.parsed_workspace.lifecycle

  # Load environment definition from remote environments.json file
  environment_definition = jsondecode(data.http.environment_definition.response_body)
  account_type           = try(local.environment_definition["account-type"], null)

  # Load feature policy document that defines feature enablement rules
  feature_policy = jsondecode(file("${path.root}/../../../feature-policy.json"))

  # Aggregate all features from policy and environment overrides
  all_features = distinct(concat(
    keys(try(local.feature_policy.lifecycle[local.lifecycle_from_workspace].features, {})),
    keys(try(local.feature_policy.account_type[local.account_type].features, {})),
    keys(try(local.feature_policy.workspace[terraform.workspace].features, {})),
    keys(try(local.environment_definition.feature_overrides, {}))
  ))

  # Build feature flags map with evaluation logic:
  # 1. Use environment-specific override if present (highest priority)
  # 2. Use workspace-specific rule if present
  # 3. Default to AND logic: feature enabled if both lifecycle AND account_type allow it
  # This allows features to be disabled by policy but enabled per-environment via overrides
  feature_flags = {
    for feature in local.all_features :
    feature => coalesce(
      try(local.environment_definition.feature_overrides[feature], null),
      try(local.feature_policy.workspace[terraform.workspace].features[feature], null),
      (
        try(local.feature_policy.lifecycle[local.lifecycle_from_workspace].features[feature], true) &&
        try(local.feature_policy.account_type[local.account_type].features[feature], true)
      )
    )
  }
}
