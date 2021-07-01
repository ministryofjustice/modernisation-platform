terraform {
  required_providers {
    aws = {
      version = ">= 3.47.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.0.1"
}
