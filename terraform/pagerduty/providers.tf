provider "pagerduty" {
  token = var.pagerduty_token
}
provider "pagerduty" {
  alias = "pagerduty_user_api"
  token = var.pagerduty_user_token
  
}
provider "aws" {
  region = "eu-west-2"
}
