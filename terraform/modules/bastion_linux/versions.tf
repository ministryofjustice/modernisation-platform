terraform {
  required_providers {
    aws = {
      version = ">= 3.37.0"
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 0.14.2"
}
