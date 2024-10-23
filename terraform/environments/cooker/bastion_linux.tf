
locals {
  public_key_data = jsondecode(file("./bastion_linux.json"))
}

# tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
module "bastion_linux" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-bastion-linux?ref=95ed3c3f454e2014a62990aacd5d68c64d026f11" # v4.2.1

  providers = {
    aws.share-host   = aws.core-vpc # core-vpc-(environment) holds the networking for all accounts
    aws.share-tenant = aws          # The default provider (unaliased, `aws`) is the tenant
  }

  # s3 - used for logs and user ssh public keys
  bucket_name = "bastion"
  # public keys
  public_key_data = local.public_key_data.keys[local.environment]
  # logs
  log_auto_clean       = "Enabled"
  log_standard_ia_days = 30  # days before moving to IA storage
  log_glacier_days     = 60  # days before moving to Glacier
  log_expiry_days      = 180 # days before log expiration
  # bastion
  allow_ssh_commands = false

  app_name      = var.networking[0].application
  business_unit = local.vpc_name
  subnet_set    = local.subnet_set
  environment   = "sandbox"
  region        = "eu-west-2"

  # Tags
  tags_common = local.tags
  tags_prefix = terraform.workspace
}
