terraform {
  required_providers {
    aws = {
      version = "~> 5.3"
      source  = "hashicorp/aws"
    }
    archive = {
      version = "~> 2.0"
      source  = "hashicorp/archive"
    }
  }
  required_version = "~> 1.0"
}
