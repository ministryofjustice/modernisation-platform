terraform {
  required_version = ">= 0.13.5"
  required_providers {
    aws = {
      version = ">= 3.13.0"
      source  = "hashicorp/aws"
    }
    local = {
      version = ">= 2.0.0"
      source  = "hashicorp/local"
    }
  }
}
