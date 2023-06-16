provider "pagerduty" {
  token      = var.pagerduty_token
  user_token = var.pagerduty_user_token
}
provider "aws" {
  region = "eu-west-2"
}
