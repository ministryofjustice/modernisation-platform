locals {
  grafana_configuration = yamldecode(file("${path.module}/tenant-configuration.yaml"))

  all_sso_uuids = distinct(flatten([
    for team_name, team_config in local.grafana_configuration : [
      lookup(team_config, "sso_uuid", [])
    ]
  ]))

  all_cloudwatch_sources = distinct(flatten([
    for team_name, team_config in local.grafana_configuration : [
      lookup(team_config, "cloudwatch_sources", [])
    ]
  ]))

  all_prometheus_sources = distinct(flatten([
    for team_name, team_config in local.grafana_configuration : [
      lookup(team_config, "prometheus_sources", [])
    ]
  ]))
}

module "managed_grafana" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 2.0"

  name = local.application_name

  license_type      = "ENTERPRISE"
  associate_license = true

  account_access_type       = "CURRENT_ACCOUNT"
  authentication_providers  = ["AWS_SSO"]
  permission_type           = "SERVICE_MANAGED"
  data_sources              = ["CLOUDWATCH", "PROMETHEUS"]
  notification_destinations = ["SNS"]

  iam_role_policy_arns = [module.amazon_managed_grafana_remote_cloudwatch_iam_policy.arn]

  role_associations = {
    "ADMIN" = {
      "group_ids" = ["16a2d234-1031-70b5-2657-7f744c55e48f"] # observability-platform
    }
    "VIEWER" = {
      "group_ids" = local.all_sso_uuids
    }
  }

  tags = local.tags
}

/* Grafana API */
locals {
  expiration_days    = 30
  expiration_seconds = 60 * 60 * 24 * local.expiration_days
}

resource "time_rotating" "rotate" {
  rotation_days = local.expiration_days
}

resource "time_static" "rotate" {
  rfc3339 = time_rotating.rotate.rfc3339
}

resource "aws_grafana_workspace_api_key" "automation_key" {
  workspace_id = module.managed_grafana.workspace_id

  key_name        = "automation"
  key_role        = "ADMIN"
  seconds_to_live = local.expiration_seconds

  lifecycle {
    replace_triggered_by = [
      time_static.rotate
    ]
  }
}


module "cloudwatch_sources" {
  source = "./modules/cloudwatch-source"

  datasource_names       = local.all_cloudwatch_sources
  environment_management = local.environment_management
}

module "prometheus_sources" {
  source = "./modules/prometheus-source"

  datasource_names       = local.all_prometheus_sources
  workspace_arn          = module.managed_prometheus.workspace_arn
  environment_management = local.environment_management
}

module "grafana_teams" {
  for_each = {
    for team_name, team_config in local.grafana_configuration : team_name => team_config
  }

  source      = "./modules/rbac"
  team_name   = each.key
  team_config = each.value

  depends_on = [
    module.cloudwatch_sources
  ]
}
