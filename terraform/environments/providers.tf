# AWS provider (default): the MoJ root account
provider "aws" {
  region = "eu-west-2"
}

# AWS provider (Modernisation Platform): the Modernisation Platform account
provider "aws" {
  alias  = "modernisation-platform"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.modernisation_platform_account.id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider (Modernisation Platform): the Modernisation Platform account in eu-west-1 (replica region)
provider "aws" {
  alias  = "modernisation-platform-eu-west-1"
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.modernisation_platform_account.id}:role/OrganizationAccountAccessRole"
  }
}


provider "github" {
  owner = "ministryofjustice"
  token = var.github_token
}
