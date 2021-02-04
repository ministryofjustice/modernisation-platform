terraform {
  required_version = ">= 0.14.2"
  required_providers {
    aws = {
      version = ">= 3.20.0"
      source  = "hashicorp/aws"
    }
    archive = {
      version = ">= 2.0.0"
      source  = "hashicorp/archive"
    }
  }
}
