terraform {
  required_providers {
    aws = {
      version = "~> 6.0"
      source  = "hashicorp/aws"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14.0"
    }
  }
  required_version = "~> 1.0"
}
