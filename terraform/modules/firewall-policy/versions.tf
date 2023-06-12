terraform {
  required_providers {
    aws = {
      version = "~> 5.2"
      source  = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
  required_version = ">= 1.0"
}
