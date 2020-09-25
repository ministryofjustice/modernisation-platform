terraform {
  # `backend` blocks do not support variables, so the bucket name is hard-coded here, although created in the s3.tf file.
  backend "s3" {
    bucket  = "modernisation-platform-terraform-state"
    region  = "eu-west-2"
    key     = "global-resources/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "environments"
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${local.environments_management.root_account_id}:role/${local.environments_management.root_account_role}"
  }
}
