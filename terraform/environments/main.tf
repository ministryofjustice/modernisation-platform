terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in s3.tf
  backend "s3" {
    acl     = "bucket-owner-full-control"
    bucket  = "modernisation-platform-terraform-state"
    encrypt = true
    key     = "environments/terraform.tfstate"
    region  = "eu-west-2"
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

# AWS provider (Modernisation Platform): the Modernisation Platform account in eu-west-1 (replica region)
provider "aws" {
  alias  = "modernisation-platform-eu-west-1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.modernisation_platform_account.id}:role/OrganizationAccountAccessRole"
  }
}


provider "github" {
  owner = "ministryofjustice"
  token = var.github_token
}
