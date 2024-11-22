# AWS provider (default)
provider "aws" {
  region = "eu-west-2"
}

# AWS provider (AWS root account for AWS SSO management)
provider "aws" {
  region = "eu-west-2"
  alias  = "sso-management"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.aws_organizations_root_account_id}:role/ModernisationPlatformSSOAdministrator"
  }
}

# AWS provider (workspace): the workspace account. Required for assuming a role into an account for bootstrapping
provider "aws" {
  alias  = "workspace"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess"
  }
}

# AWS provider for the Modernisation Platform, to get things from there if required
provider "aws" {
  alias  = "core-shared-services"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/ModernisationPlatformAccess"
  }
}

provider "aws" {
  alias  = "modernisation-secret-read"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_ssm_parameter.modernisation_platform_account_id.value}:role/modernisation-account-limited-read-member-access"
  }
}
