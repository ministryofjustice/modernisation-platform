provider "pagerduty" {
  token = var.pagerduty_token
}

provider "aws" {
  region = "eu-west-2"
}
