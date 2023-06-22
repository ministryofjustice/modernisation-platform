data "aws_caller_identity" "current" {}

module "ram-principal-association" {

  count = (var.networking[0].set == "") ? 0 : 1

  source = "../../modules/ram-principal-association"

  providers = {
    aws.share-acm    = aws.core-network-services
    aws.share-host   = aws.core-vpc
    aws.share-tenant = aws
  }
  principal   = data.aws_caller_identity.current.account_id
  vpc_name    = var.networking[0].business-unit
  subnet_set  = var.networking[0].set
  acm_pca     = "acm-pca-${local.is_live[0]}"
  environment = local.environment

}

data "aws_ami_ids" "example" {
  owners     = ["self"]
  name_regex = "^(?!oracle-linux-5.11)*"
  # filter {
  #   name   = "name"
  #   values = ["oracle-linux-5.11*"]
  # }

}

output "amis" {
  value = data.aws_ami_ids.example.ids
}