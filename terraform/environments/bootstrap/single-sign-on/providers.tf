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
    role_arn = can(regex("superadmin|AdministratorAccess", data.aws_iam_session_context.whoami.issuer_arn)) ? "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess" : "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}
