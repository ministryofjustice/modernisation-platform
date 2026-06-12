terraform {
  required_providers {
    aws = {
      version = ">= 6.0, < 6.49.1"
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.0"
}
