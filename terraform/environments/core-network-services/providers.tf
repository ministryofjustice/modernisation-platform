# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
<<<<<<< HEAD
  alias  = "modernisation-platform"
  region = "eu-west-2"
=======
  alias   = "modernisation-platform"
  region  = "eu-west-2"
  version = ">= 4.0.0, < 5.0.0"
>>>>>>> de8f3cc (Commit changes made by code formatters)
}
