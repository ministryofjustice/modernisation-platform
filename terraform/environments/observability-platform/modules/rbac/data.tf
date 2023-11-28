data "aws_region" "current" {}

data "grafana_data_source" "cloudwatch" {
  for_each = var.team_config.cloudwatch_sources != null ? toset(var.team_config.cloudwatch_sources) : toset([])

  name = each.key
}

data "grafana_data_source" "prometheus" {
  for_each = var.team_config.prometheus_sources != null ? toset(var.team_config.prometheus_sources) : toset([])

  name = each.key
}