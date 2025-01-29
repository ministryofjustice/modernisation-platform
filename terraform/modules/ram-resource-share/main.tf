locals {
  resource_arns_map = { for idx, arn in var.resource_arns : idx => arn }
}
resource "aws_ram_resource_share" "default" {
  name                      = "${var.tags_prefix}-resource-share"
  allow_external_principals = false
  tags = merge(
    var.tags_common,
    {
      Name = var.tags_prefix
    },
  )
}

resource "aws_ram_resource_association" "default" {
  for_each = local.resource_arns_map

  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.default.arn
}
