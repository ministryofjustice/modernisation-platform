# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
  default_tags { tags = local.tags }
}

# AWS provider (modernisation-secrets-read): Required for assuming a role into modernisation platform account to read secrets
provider "aws" {
  alias  = "modernisation-secrets-read"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_ssm_parameter.modernisation_platform_account_id.value}:role/modernisation-account-limited-read-member-access"
  }
}

# AWS provider for the workspace you're working in but in us-east-1, to do things like accepting License Manager grants
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
  alias = "modernisation-platform-environments-us-east-1"
  default_tags { tags = local.tags }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  default_tags { tags = local.tags }
}

# AWS provider for the Modernisation Platform for us-east-1, to do things like License Manager grants
provider "aws" {
  alias  = "modernisation-platform-us-east-1"
  region = "us-east-1"
  default_tags { tags = local.tags }
}
