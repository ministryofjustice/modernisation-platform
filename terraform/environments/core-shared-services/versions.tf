terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    random = {
      version = "~> 3.0"
      source  = "hashicorp/random"
    }
  }
  required_version = "~> 1.0"
}
