######## DO NOT EDIT - THIS FILE WILL BE OVERWRITTEN BY TERRAFORM #########

data "aws_caller_identity" "current" {}

# Get the VPC network configuration to check for secondary CIDRs
data "http" "vpc_network_config" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments-networks/${var.networking[0].business-unit}-${local.environment}.json"
}

locals {
  vpc_network_config     = jsondecode(data.http.vpc_network_config.response_body)
  has_secondary_cidrs    = length(lookup(lookup(local.vpc_network_config, "options", {}), "secondary_cidr_blocks", [])) > 0
}

module "ram-principal-association" {

  count = (var.networking[0].set == "") ? 0 : 1

  source = "../../modules/ram-principal-association"

  providers = {
    aws.share-acm    = aws.core-network-services
    aws.share-host   = aws.core-vpc
    aws.share-tenant = aws
  }
  principal               = data.aws_caller_identity.current.account_id
  vpc_name                = var.networking[0].business-unit
  subnet_set              = var.networking[0].set
  acm_pca                 = "acm-pca-${local.is_live[0]}"
  environment             = local.environment
  enable_secondary_share  = local.has_secondary_cidrs

}

#ram-ec2-retagging module 
module "ram-ec2-retagging" {

  count = (var.networking[0].set == "") ? 0 : 1


  source = "../../modules/ram-ec2-retagging"
  providers = {
    aws.share-host   = aws.core-vpc
    aws.share-tenant = aws
  }

  vpc_name   = "${var.networking[0].business-unit}-${local.environment}"
  subnet_set = var.networking[0].set

  depends_on = [module.ram-principal-association[0]]
}
