# Backend
terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in modernisation-platform-account/s3.tf
  backend "s3" {
    acl                  = "bucket-owner-full-control"
    bucket               = "modernisation-platform-terraform-state"
    encrypt              = true
    key                  = "terraform.tfstate"
    region               = "eu-west-2"
    workspace_key_prefix = "environments/shared-services" # This will store the object as environments/shared-services/${workspace}/terraform.tfstate
  }
}

# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
}

# Sample outputs
## Using the Modernisation Platform provider
data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

output "modernisation-platform-account-id" {
  value = data.aws_caller_identity.modernisation-platform.account_id
}

## Using the default provider (specifying nothing)
data "aws_caller_identity" "current" {}

output "current-account-id" {
  value = data.aws_caller_identity.current.account_id
}

locals {
  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
}
