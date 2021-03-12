data "aws_caller_identity" "current" {}

module "ram-principal-association" {

  source = "../../modules/ram-principal-association"
 
  providers = {
    aws.share-acm    = aws.core-network-services-production
    aws.share-host   = aws.core-vpc-production # Core VPC production holds the share
    aws.share-tenant = aws                     # The default provider (unaliased, `aws`) is the tenant
  }

  principal  = data.aws_caller_identity.current.account_id
  vpc_name   = "garden-production"
  subnet_set = "patio"
  acm_pca    = "acm-pca-live"
}