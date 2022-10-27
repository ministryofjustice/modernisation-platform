# AWS provider (default): the MoJ root account. Required to create and assume roles into AWS accounts that are part of the AWS organisation
provider "aws" {
  region = "eu-west-2"
}

# AWS provider (workspace): the workspace account. Required for assuming a role into an account for bootstrapping
provider "aws" {
  alias  = "workspace"
  region = "eu-west-2"
  assume_role {
    role_arn = can(regex("superadmin|AdministratorAccess", data.aws_iam_session_context.whoami.issuer_arn)) ? "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/ModernisationPlatformAccess" : "arn:aws:iam::${local.environment_management.account_ids[terraform.workspace]}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider (Modernisation Platform): the Modernisation Platform account. Required to access secrets stored in the Modernisation Platform
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  assume_role {
    role_arn = can(regex("superadmin|AdministratorAccess", data.aws_iam_session_context.whoami.issuer_arn)) ? null : "arn:aws:iam::${local.modernisation_platform_account.id}:role/OrganizationAccountAccessRole"
  }
}
