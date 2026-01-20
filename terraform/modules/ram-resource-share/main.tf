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
  for_each = can(toset(var.resource_arns)) ? toset(var.resource_arns) : var.resource_arns

  resource_arn       = can(toset(var.resource_arns)) ? each.value : each.value
  resource_share_arn = aws_ram_resource_share.default.arn
}
