terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.8"
    }
  }
}
