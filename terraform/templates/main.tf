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