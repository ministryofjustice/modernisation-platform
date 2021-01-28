data "aws_caller_identity" "current" {}

module "ram-principal-association" {
  source = "../../modules/ram-principal-association"
  providers = {
    aws.share-host   = aws.core-vpc-production # Core VPC production holds the share
    aws.share-tenant = aws                     # The default provider (unaliased, `aws`) is the tenant
  }

  principal  = data.aws_caller_identity.current.account_id
  vpc_name   = "hmpps-production"
  subnet_set = "nomis"
}

#
# The below ram-ec2-retagging module needs to be run separately due to Terraform being unable to work out how many IDs there are to tag from a data lookup.
#

module "ram-ec2-retagging" {
  source = "../../modules/ram-ec2-retagging"
  providers = {
    aws.share-host   = aws.core-vpc-production # Core VPC production holds the share
    aws.share-tenant = aws                     # The default provider (unaliased, `aws`) is the tenant
  }

  vpc_name   = "hmpps-production"
  subnet_set = "nomis"

  depends_on = [module.ram-principal-association]
}
