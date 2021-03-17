########### DO NOT EDIT - THIS FILE WILL BE OVERWRITTEN BY TERRAFORM #########
data "aws_caller_identity" "current" {}

module "ram-principal-association" {

  count = (local.file_exists == true) ? 1 : 0

  source = "../../modules/ram-principal-association"

  providers = {
    aws.share-acm    = aws.core-network-services
    aws.share-host   = aws.core-vpc
    aws.share-tenant = aws
  }
  principal  = data.aws_caller_identity.current.account_id
  vpc_name   = "${local.vpc_name}${local.environment}"
  subnet_set = local.subnet_set
  acm_pca    = local.acm_pca[0]

}

#ram-ec2-retagging module 
module "ram-ec2-retagging" {

  count = (local.file_exists == true) ? 1 : 0

  source = "../../modules/ram-ec2-retagging"
  providers = {
    aws.share-host   = aws.core-vpc-production
    aws.share-tenant = aws
  }
  vpc_name   = "${local.vpc_name}${local.environment}"
  subnet_set = local.subnet_set

  depends_on = [module.ram-principal-association.aws_ram_principal_association]
}




