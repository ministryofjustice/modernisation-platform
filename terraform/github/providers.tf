provider "github" {
  owner = "ministryofjustice"
  token = var.github_token
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  region = "eu-west-2"
  alias  = "testing-test"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:role/ModernisationPlatformAccess"
  }
}
