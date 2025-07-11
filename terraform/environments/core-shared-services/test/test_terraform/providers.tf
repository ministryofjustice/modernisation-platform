# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
}
terraform {
  required_providers {
    aws = {
      version = "~> 6.3"
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.0"
}