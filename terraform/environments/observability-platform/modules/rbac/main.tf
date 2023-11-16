resource "grafana_team" "data_platform" {
  for_each = var.grafana_rbac
  name     = each.key
  team_sync {
    groups = each.value.accounts
  }
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Amazon Managed Prometheus"
  is_default = true
  url        = "https://aps-workspaces.${data.aws_region.current.name}.amazonaws.com/workspaces/${var.workspace_id}"

  json_data_encoded = jsonencode({
    httpMethod    = "POST"
    sigV4Auth     = true
    sigV4AuthType = "ec2_iam_role"
    sigV4Region   = data.aws_region.current.name
  })
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "Amazon CloudWatch"

  json_data_encoded = jsonencode({
    authType      = "ec2_iam_role"
    defaultRegion = data.aws_region.current.name
  })
}

resource "grafana_data_source_permission" "cloudwatch" {
  for_each      = var.grafana_rbac
  datasource_id = grafana_data_source.cloudwatch.id

  permissions {
    team_id    = grafana_team.data_platform[each.key].id
    permission = "Query"
  }
}
