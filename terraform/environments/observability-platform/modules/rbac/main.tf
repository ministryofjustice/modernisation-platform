resource "grafana_team" "data_platform" {
  name     = var.team_name
  team_sync {
    groups = toset([var.team_config.sso_uuid])
  }
}

resource "grafana_data_source_permission" "permission_cloudwatch" {
  for_each = data.grafana_data_source.cloudwatch

  datasource_id = each.value.id

  permissions {
    team_id    = var.team_config.sso_uuid
    permission = var.team_config.permission
  }
}

resource "grafana_data_source_permission" "permission_prometheus" {
  for_each = data.grafana_data_source.prometheus

  datasource_id = each.value.id

  permissions {
    team_id    = var.team_config.sso_uuid
    permission = var.team_config.permission
  }
}