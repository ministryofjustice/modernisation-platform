terraform {
  # `backend` blocks do not support variables, so the bucket name is hard-coded here, although created in the global-resources/s3.tf file.
  # The user that this Terraform configuration should be run as, has access to this bucket.
  backend "s3" {
    bucket  = "modernisation-platform-terraform-state"
    region  = "eu-west-2"
    key     = "environments/terraform.tfstate"
    encrypt = true
  }
}

# AWS provider (default): the MoJ root account
provider "aws" {
  region = "eu-west-2"
}

# AWS provider (Modernisation Platform): the Modernisation Platform account
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.modernisation_platform_account.id}:role/OrganizationAccountAccessRole"
  }
}
