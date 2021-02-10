provider "github" {
  organization = "ministryofjustice"
  token        = var.github_token
}

provider "aws" {
  region = "eu-west-2"
}
