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

provider "aws" {
  alias  = "modernisation-platform-eu-west-1"
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-logging-production"]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for core-network-services to get the Transit Gateway attachment
provider "aws" {
  alias  = "core-network-services"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-network-services-production"]}:role/ModernisationPlatformAccess"
  }
}
