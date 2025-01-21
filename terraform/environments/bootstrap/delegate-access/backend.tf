terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in terraform/modernisation-platform-account/s3.tf
  #checkov:skip=CKV_TF_3:Ensure state files are locked - temporarily suppressed pending issue #8789
  backend "s3" {
    acl                  = "bucket-owner-full-control"
    bucket               = "modernisation-platform-terraform-state"
    encrypt              = true
    key                  = "terraform.tfstate"
    region               = "eu-west-2"
    use_lockfile         = true
    workspace_key_prefix = "environments/bootstrap/delegate-access" # This will store the object as environments/bootstrap/delegate-access/${workspace}/terraform.tfstate
  }
}
