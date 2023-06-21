terraform {
  required_version = ">= 1.0.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = "~> 2.6"
    }
  }
}
