# Sharing
# provider "aws" {
#   alias  = "core-vpc-production"
#   region = "eu-west-2"

#   assume_role {
#     role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-vpc-production"]}:role/ModernisationPlatformAccess"
#   }
# }


module "bastion_linux" {
  source = "../../modules/bastion_linux"

  providers = {
    aws.share-host   = aws.core-vpc-production # Core VPC production holds the share
    aws.share-tenant = aws                     # The default provider (unaliased, `aws`) is the tenant
  }

  business_unit         = var.business_unit
  subnet_set            = var.subnet_set
  account_name          = var.account_name
  region                = "eu-west-2"
  bastion_host_key_pair = "dm_sandbox"

  # Tags
  tags_common = local.tags
  tags_prefix = terraform.workspace
}

# output "test" {
#   value = module.bastion_linux.test
# }