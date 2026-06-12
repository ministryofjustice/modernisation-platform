terraform {
  required_providers {
    aws = {
      version = ">= 6.0, < 6.49.1"
      source  = "hashicorp/aws"
    }
    github = {
      version = "~> 6.0"
      source  = "integrations/github"
    }
  }
  required_version = "~> 1.0"
}
