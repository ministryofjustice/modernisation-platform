terraform {
  required_providers {
    aws = {
      version = ">= 3.20.0"
      source  = "hashicorp/aws"
    }
    time = {
      version = ">= 0.6.0"
      source  = "hashicorp/time"
    }
  }
  required_version = ">= 0.14.2"
}
