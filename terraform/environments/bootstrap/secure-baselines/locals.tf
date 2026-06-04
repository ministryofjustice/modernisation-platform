# This data source allows us to get the AWS Organization's root account information from a Organization member account.
# We use that to ensure a Modernisation Platform member account remains part of the AWS Organization.
data "aws_organizations_organization" "root_account" {}

# To Get Modernisation Platform Account Number
data "aws_ssm_parameter" "modernisation_platform_account_id" {
  name = "modernisation_platform_account_id"
}

locals {
  enable-cloudtrail-events         = strcontains(terraform.workspace, "digital-prison-reporting") ? false : true
  reduced_preprod_backup_retention = strcontains(terraform.workspace, "ccms-ebs") ? true : false
  enabled_baseline_regions = [
    "eu-central-1", # Europe (Frankfurt)
    "eu-west-1",    # Europe (Ireland)
    "eu-west-2",    # Europe (London)
    "eu-west-3",    # Europe (Paris)
    "us-east-1",    # US East (N. Virginia) (for global services)
  ]
  environments = {
    business-unit = "Platforms"
    service-area  = "Hosting"
    application   = "Modernisation Platform: Environments Management"
    is-production = true
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
    component     = "secure-baselines"
    source-code   = "https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/environments/bootstrap/secure-baselines"
  }
  root_account           = data.aws_organizations_organization.root_account
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  mp_owned_workspaces = [
    "long-term-storage-production",
    "^core-.*"
  ]
  is_core_account = length(regexall(join("|", local.mp_owned_workspaces), terraform.workspace)) > 0

  # Locals that are passed to the Baselines module for slack alerts for SecurityHub issues.
  securityhub_slack_alerts_accounts        = local.is_core_account && !strcontains(terraform.workspace, "core-shared-services") # All core accounts excluding terraform workspaces containing core-shared-services.
  securityhub_slack_alerts_scope           = ["CRITICAL", "HIGH"]                                                               # The type of alert to generate alerts for. 
  enable_securityhub_event_forwarding      = local.is_core_account
  securityhub_central_event_bus_account_id = local.environment_management.account_ids["observability-platform-production"]
  securityhub_central_event_bus_arn = format(
    "arn:aws:events:%s:%s:event-bus/securityhub-central",
    "eu-west-2",
    local.securityhub_central_event_bus_account_id,
  )
}
