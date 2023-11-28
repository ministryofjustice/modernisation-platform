resource "grafana_data_source" "prometheus" {
  for_each = toset(var.datasource_names)

  type       = "prometheus"
  name       = each.key
  is_default = true
  url        = "https://aps-workspaces.${data.aws_region.current.name}.amazonaws.com/workspaces/${var.workspace_id}"

  json_data_encoded = jsonencode({
    httpMethod    = "POST"
    sigV4Auth     = true
    sigV4AuthType = "ec2_iam_role"
    sigV4Region   = data.aws_region.current.name
  })
}