terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in terraform/modernisation-platform-account/s3.tf
  backend "s3" {
    acl                  = "bucket-owner-full-control"
    bucket               = "modernisation-platform-terraform-state"
    encrypt              = true
    key                  = "terraform.tfstate"
    region               = "eu-west-2"
<<<<<<< HEAD
    workspace_key_prefix = "environments/bootstrap/iam-baselines" # This will store the object as environments/bootstrap/delegate-access/${workspace}/terraform.tfstate
=======
    workspace_key_prefix = "environments/bootstrap/iam-baseline" # This will store the object as environments/bootstrap/delegate-access/${workspace}/terraform.tfstate
>>>>>>> 4fcf9eb7868f61fb07c0d408d88f6d34ef215ce6
  }
}
