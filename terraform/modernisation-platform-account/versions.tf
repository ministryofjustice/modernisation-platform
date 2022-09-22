terraform {
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
    archive = {
      version = "~> 2.2"
      source  = "hashicorp/archive"
    }
  }
  required_version = "~> 1.0"
}
