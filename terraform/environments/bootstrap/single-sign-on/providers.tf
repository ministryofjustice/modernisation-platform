# This data sources allows us to get the AWS root account information for use elsewhere
# (when we want to assume a role in the root account, as below)
data "aws_organizations_organization" "root_account" {}

# AWS provider (default)
provider "aws" {
  region = "eu-west-2"
}

# AWS provider (AWS root account for AWS SSO management)
provider "aws" {
  region = "eu-west-2"
  alias  = "sso-management"
  assume_role {
    role_arn = "arn:aws:iam::${data.aws_organizations_organization.root_account.master_account_id}:role/ModernisationPlatformSSOAdministrator"
  }
}
