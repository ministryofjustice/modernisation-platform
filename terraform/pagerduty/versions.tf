terraform {
  required_version = ">= 1.0.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3"
    }
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "~> 2.6"
    }
  }
}
