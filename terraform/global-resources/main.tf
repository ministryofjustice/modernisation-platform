terraform {
  # `backend` blocks do not support variables, so the bucket name is hard-coded here, although created in the s3.tf file.
  backend "s3" {
    bucket = "modernisation-platform-terraform-state"
    region = "eu-west-2"
    key    = "global-resources/terraform.tfstate"
  }
}

provider "aws" {
  region = "eu-west-2"
}
