terraform {
  required_providers {
    aws = {
      version = ">= 6.0.0, < 7.0.0, != 6.69.0"
      source  = "hashicorp/aws"
    }
    archive = {
      version = "~> 2.0"
      source  = "hashicorp/archive"
    }
  }
  required_version = "~> 1.0"
}
