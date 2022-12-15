terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
    github = {
      version = "~> 5.2"
      source  = "integrations/github"
    }
    time = {
      version = "~> 0.9"
      source  = "hashicorp/time"
    }
    http = {
      version = "~> 3.0"
      source  = "hashicorp/http"
    }
  }
}
