# AWS provider (default): the Modernisation Platform account, which this Terraform configuration should be called using.
provider "aws" {
  region = "eu-west-2"
}

# AWS provider (workspace): the workspace account. Required for assuming a role into an account for bootstrapping
provider "aws" {
  alias  = "workspace"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

# Region specific providers for the workspace. Required for bootstrapping resources in enabled regions.
provider "aws" {
  alias       = "workspace-eu-central-1"
  region      = "eu-central-1"
  max_retries = 100

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

provider "aws" {
  alias       = "workspace-eu-west-1"
  region      = "eu-west-1"
  max_retries = 100

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

provider "aws" {
  alias       = "workspace-eu-west-2"
  region      = "eu-west-2"
  max_retries = 100

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

provider "aws" {
  alias       = "workspace-eu-west-3"
  region      = "eu-west-3"
  max_retries = 100

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}


provider "aws" {
  alias       = "workspace-us-east-1"
  region      = "us-east-1"
  max_retries = 100

  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for core-logging
provider "aws" {
  alias  = "core-logging"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-logging-production"]}:role/ModernisationPlatformAccess"
  }
}