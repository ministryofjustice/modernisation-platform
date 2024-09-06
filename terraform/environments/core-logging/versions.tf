terraform {
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
    http = {
      version = "~> 3.0"
      source  = "hashicorp/http"
    }
    archive = {
      version = "~> 2.0"
      source  = "hashicorp/archive"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }
  required_version = "~> 1.0"
}
