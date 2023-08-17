data "aws_ram_resource_share" "protected" {
  provider = aws.core-vpc

  name = "${var.networking[0].business-unit}-${local.environment}-protected-resource-share" # Resource share to lookup

  resource_owner = "SELF"

  filter {
    name   = "Name"
    values = ["${var.networking[0].business-unit}-${local.environment}-protected"]
  }
}

resource "aws_ram_principal_association" "protected" {
  provider = aws.core-vpc

  principal          = data.aws_caller_identity.current.account_id
  resource_share_arn = data.aws_ram_resource_share.protected.arn
}