
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
# List all resource shares and check if secondary exists (won't fail if not found)
data "aws_ram_resource_shares" "all_shares" {
  count = var.enable_secondary_share ? 1 : 0
  provider = aws.share-host
  resource_owner = "SELF"
  
  filter {
    name   = "name"
    values = ["*-secondary-resource-share"]
  }
}

locals {
  # Check if the specific secondary resource share exists
  secondary_share_name = "${var.vpc_name}-${var.environment}-${var.subnet_set}-secondary-resource-share"
  secondary_share_exists = var.enable_secondary_share && length(data.aws_ram_resource_shares.all_shares) > 0 ? contains(
    [for arn in data.aws_ram_resource_shares.all_shares[0].arns : 
      try(data.aws_ram_resource_shares.all_shares[0].names[index(data.aws_ram_resource_shares.all_shares[0].arns, arn)], "")
    ],
    local.secondary_share_name
  ) : false
  
  # Get the ARN if it exists
  secondary_share_arn = local.secondary_share_exists && length(data.aws_ram_resource_shares.all_shares) > 0 ? [
    for arn in data.aws_ram_resource_shares.all_shares[0].arns :
    arn if try(data.aws_ram_resource_shares.all_shares[0].names[index(data.aws_ram_resource_shares.all_shares[0].arns, arn)], "") == local.secondary_share_name
  ][0] : ""
}

resource "aws_ram_principal_association" "secondary" {
  provider = aws.share-host
  count    = local.secondary_share_exists ? 1 : 0

  principal          = var.principal
  resource_share_arn = local.secondary_share_arn
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
