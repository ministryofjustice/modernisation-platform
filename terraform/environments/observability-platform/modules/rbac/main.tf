resource "grafana_team" "this" {
  name = var.team_name
  team_sync {
    groups = toset([var.team_config.sso_uuid])
  }
}

resource "grafana_folder" "this" {
  title = var.team_name
}

resource "grafana_folder_permission" "this" {
  folder_uid = grafana_folder.this.uid

  permissions {
    team_id    = grafana_team.this.id
    permission = "Edit"
  }
}

data "grafana_data_source" "this" {
  for_each = toset(var.team_config.cloudwatch_sources)

  name = "${each.key}-cloudwatch"
}

resource "grafana_data_source_permission" "permission_cloudwatch" {
  for_each = data.grafana_data_source.cloudwatch

  datasource_id = data.grafana_data_source.this[each.key].id

  permissions {
    team_id    = grafana_team.this.id
    permission = "Query"
  }
}
