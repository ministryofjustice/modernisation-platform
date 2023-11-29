resource "grafana_data_source" "cloudwatch" {
  for_each = toset(var.datasource_names)

  type = "cloudwatch"
  name = each.key

  json_data_encoded = jsonencode({
    authType        = "ec2_iam_role"
    defaultRegion   = data.aws_region.current.name
    assume_role_arn = "arn:aws:iam::${var.environment_management.account_ids[each.key]}:role/${var.role_name}"
  })
}
