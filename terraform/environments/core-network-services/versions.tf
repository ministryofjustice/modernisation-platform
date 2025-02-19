terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.12.1"
    }
  }
  required_version = "~> 1.0"
}
