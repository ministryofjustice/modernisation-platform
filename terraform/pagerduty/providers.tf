provider "pagerduty" {
  token      = var.pagerduty_token
  user_token = var.pagerduty_user_token
}
provider "aws" {
  region = "eu-west-2"
}


# kms replica region
provider "aws" {
  alias  = "modernisation-platform-eu-west-1"
  region = "eu-west-1"
}
