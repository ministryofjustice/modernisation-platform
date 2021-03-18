provider "aws" {
  alias = "share-host" # Provider that holds the resource share
}

provider "aws" {
  alias = "share-tenant" # Provider that wants to be shared with
}

provider "aws" {
  alias = "share-acm" # Provider that wants to be shared with
}

data "aws_ram_resource_share" "default" {
  provider = aws.share-host
  
  name     = "${var.vpc_name}-${var.environment}-${var.subnet_set}-resource-share" # Resource share to lookup

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
