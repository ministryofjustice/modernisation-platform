terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
    github = {
      version = "~> 4.4"
      source  = "integrations/github"
    }
  }
}
