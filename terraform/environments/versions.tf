terraform {
  required_providers {
    aws = {
      version = ">= 4.0.0, < 6.0.0"
      source  = "hashicorp/aws"
    }
    github = {
      version = "~> 5.2"
      source  = "integrations/github"
    }
  }
  required_version = "~> 1.0"
}
