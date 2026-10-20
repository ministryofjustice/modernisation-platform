terraform {
  required_providers {
    aws = {
      version = ">= 6.0.0, < 7.0.0, != 6.69.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = "~> 1.0"
}
