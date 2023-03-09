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
# AWS provider (workspace): the workspace account. Required for assuming a role into an account for bootstrapping
provider "aws" {
  alias  = "workspace-us-east"
  region = "us-east-1"
  assume_role {
    role_arn = can(regex("superadmin|AdministratorAccess", data.aws_iam_session_context.whoami.issuer_arn)) ? "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess" : "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}