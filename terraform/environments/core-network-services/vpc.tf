module "live_vpc" {
  source = "./modules/core-vpc"

  vpc_cidr                = var.live_vpc_cidr
  private_tgw_cidr_blocks = var.live_private_tgw_cidr_blocks
  private_cidr_blocks     = var.live_private_cidr_blocks
  public_cidr_blocks      = var.live_public_cidr_blocks
  tags_common             = local.tags
  tags_prefix             = "live"
}

module "non_live_vpc" {
  source = "./modules/core-vpc"

  vpc_cidr                = var.non_live_vpc_cidr
  private_tgw_cidr_blocks = var.non_live_private_tgw_cidr_blocks
  private_cidr_blocks     = var.non_live_private_cidr_blocks
  public_cidr_blocks      = var.non_live_public_cidr_blocks
  tags_common             = local.tags
  tags_prefix             = "non_live"
}
