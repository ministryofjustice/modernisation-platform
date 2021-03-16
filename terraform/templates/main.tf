data "aws_caller_identity" "current" {}

module "ram-principal-association" {

  source = "../../modules/ram-principal-association"
 
  providers = {
    aws.share-acm    = aws.core-network-services-production
    aws.share-host   = aws.core-vpc-production 
    aws.share-tenant = aws                    
  }

  principal  = data.aws_caller_identity.current.account_id
  vpc_name = terraform.workspace
  subnet_set = local.json_data.networking[0].set
  acm_pca    = local.acm_pca[0]

}

#ram-ec2-retagging module 


module "ram-ec2-retagging" {
  source = "../../modules/ram-ec2-retagging"
  providers = {
    aws.share-host   = aws.core-vpc-production # Core VPC production holds the share
    aws.share-tenant = aws                     # The default provider (unaliased, `aws`) is the tenant
  }

  vpc_name = local.json_data.networking[0].business-unit
  subnet_set = local.json_data.networking[0].set

  depends_on = [module.ram-principal-association]
}
