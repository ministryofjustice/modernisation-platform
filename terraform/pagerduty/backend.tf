terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in modernisation-platform-account/s3.tf
  #checkov:skip=CKV_TF_3:Ensure state files are locked - temporarily suppressed pending issue #8789
  backend "s3" {
    bucket  = "modernisation-platform-terraform-state"
    encrypt = true
    key     = "pagerduty/terraform.tfstate"
    region  = "eu-west-2"
  }
}