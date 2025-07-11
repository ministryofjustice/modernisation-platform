terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "~> 3.15"
    }
  }
  required_version = "~> 1.0"
}
