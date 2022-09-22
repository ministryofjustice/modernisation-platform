terraform {
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
    github = {
      version = "~> 4.0"
      source  = "integrations/github"
    }
  }
  required_version = "~> 1.0"
}
