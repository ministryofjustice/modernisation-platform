locals {
  share_secondary = var.vpc_name == "hmpps" && var.environment == "production" ? true : false
}

data "aws_ram_resource_share" "default" {
  provider = aws.share-host

  name = "${var.vpc_name}-${var.environment}-${var.subnet_set}-resource-share" # Resource share to lookup

  resource_owner = "SELF"

  filter {
    name   = "Name"
    values = ["${var.vpc_name}-${var.environment}-${var.subnet_set}"]
  }
}

resource "aws_ram_principal_association" "default" {
  provider = aws.share-host

  principal          = var.principal
  resource_share_arn = data.aws_ram_resource_share.default.arn
}

# Secondary CIDR subnet share association
data "aws_ram_resource_share" "secondary" {
  count    = local.share_secondary ? 1 : 0
  provider = aws.share-host

  name = "${var.vpc_name}-${var.environment}-${var.subnet_set}-secondary-resource-share"

  resource_owner = "SELF"

  filter {
    name   = "Name"
    values = ["${var.vpc_name}-${var.environment}-${var.subnet_set}-secondary"]
  }
}

resource "aws_ram_principal_association" "secondary" {
  provider = aws.share-host
  count = local.share_secondary ? 1 : 0

  principal          = var.principal
  resource_share_arn = data.aws_ram_resource_share.secondary[0].arn
}

#configure acm certificate share association
data "aws_ram_resource_share" "acm" {
  provider = aws.share-acm
  name     = var.acm_pca # Resource share to lookup

  resource_owner = "SELF"

  filter {
    name   = "Name"
    values = [var.acm_pca]
  }
}

resource "aws_ram_principal_association" "acm" {
  provider = aws.share-acm

  principal          = var.principal
  resource_share_arn = data.aws_ram_resource_share.acm.arn
}