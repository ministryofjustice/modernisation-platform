terraform {
  required_providers {
    aws = {
      version = "~> 6.0"
      source  = "hashicorp/aws"
    }
    github = {
      version = "6.8.3"
      source  = "integrations/github"
    }
  }
  required_version = "~> 1.0"
}
