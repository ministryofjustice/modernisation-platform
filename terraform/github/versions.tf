terraform {
  required_version = ">= 0.14.2"
  required_providers {
    aws = {
      version = ">= 3.20.0"
      source  = "hashicorp/aws"
    }
    github = {
      version = ">= 4.4.0"
      source  = "integrations/github"
    }
  }
}
