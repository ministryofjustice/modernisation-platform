terraform {
  required_providers {
    aws = {
      version     = "~> 5.0"
      source      = "hashicorp/aws"
      max_retries = 100
    }
  }
  required_version = "~> 1.0"
}
