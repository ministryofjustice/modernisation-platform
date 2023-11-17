module "managed_grafana" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 2.0"

  name = local.application_name

  # license_type = "ENTERPRISE_FREE_TRIAL"
  associate_license = false

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
    "EDITOR" = {
      "group_ids" = [
        "7652b2d4-d0d1-707f-66ae-0b176587547e" # data-platform-labs
      ]
    }
  }

  tags = local.tags
}

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

module "grafana_teams" {
  source  = "./modules/rbac"

  grafana_rbac = {
    "data-platform-apps-and-tools" = {
      accounts = ["data-platform-apps-and-tools", "data-platform"]
      permission = "Edit"
    },
    "data-platform-labs" = {
      accounts = ["data-platform"]
      permission = "Query"
    }
  }
  workspace_id = module.managed_grafana.workspace_id
}