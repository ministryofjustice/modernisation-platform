terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in terraform/modernisation-platform-account/s3.tf
  backend "s3" {
    acl          = "bucket-owner-full-control"
    bucket       = "modernisation-platform-terraform-state"
    encrypt      = true
    key          = "single-sign-on/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}
