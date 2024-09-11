terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    http = {
      version = "~> 3.0"
      source  = "hashicorp/http"
    }
  }
  pagerduty = {
    source  = "pagerduty/pagerduty"
    version = ">= 2.2.1"
  }  
  required_version = "~> 1.0"
}
