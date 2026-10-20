terraform {
  required_providers {
    aws = {
      version = ">= 6.0.0, < 7.0.0, != 6.69.0"
      source  = "hashicorp/aws"
    }
    github = {
      version = "~> 6.0"
      source  = "integrations/github"
    }
  }
  required_version = "~> 1.0"
}
