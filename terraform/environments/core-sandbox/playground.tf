######### DO NOT EDIT - THIS FILE WILL BE OVERWRITTEN BY TERRAFORM #########

data "aws_caller_identity" "current" {}


module "ram-principal-association" {

  count = (var.networking[0].set == "") ? 0 : 1

  source = "../../modules/ram-principal-association"

  providers = {
    aws.share-acm    = aws.core-network-services
    aws.share-host   = aws.core-vpc
    aws.share-tenant = aws
  }
  principal = data.aws_caller_identity.current.account_id
  #vpc_name   = "${local.vpc_name}${local.environment}" 
<<<<<<< HEAD
  vpc_name =   terraform.workspace 
  subnet_set = var.networking[0].set
  acm_pca    = local.acm_pca[0]
  environment = var.environment
=======
  vpc_name   = "garden-production"
  subnet_set = local.subnet_set
  acm_pca    = local.acm_pca[0]

>>>>>>> 470cf89972b8c743e85f4bc22e93f49196c22900
}

#ram-ec2-retagging module 
module "ram-ec2-retagging" {

  count = (var.networking[0].set == "") ? 0 : 1


  source = "../../modules/ram-ec2-retagging"
  providers = {
    aws.share-host   = aws.core-vpc
    aws.share-tenant = aws
  }
  #vpc_name   = "${local.vpc_name}${local.environment}"
<<<<<<< HEAD
  vpc_name = "garden-production"
  #vpc_name = var.networking[0].business-unit 
  subnet_set = var.networking[0].set
  environment = var.environment
=======
  vpc_name   = "garden-production"
  subnet_set = local.subnet_set

  depends_on = [module.ram-principal-association.aws_ram_principal_association]
}
>>>>>>> 470cf89972b8c743e85f4bc22e93f49196c22900

  depends_on = [module.ram-principal-association[0]] 
}