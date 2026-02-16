terraform {
  required_providers {
    aws = {
      version = ">= 6.0, < 6.32.2"
      source  = "hashicorp/aws"
    }
    http = {
      version = "~> 3.0"
      source  = "hashicorp/http"
    }
  }
  required_version = "~> 1.0"
}
