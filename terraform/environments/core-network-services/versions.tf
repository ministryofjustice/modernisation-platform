terraform {
  required_providers {
    aws = {
      version = "~> 6.3"
      source  = "hashicorp/aws"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.0"
    }
  }
  required_version = "~> 1.0"
}
