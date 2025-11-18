terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      version = "~> 6.0"
      source  = "hashicorp/aws"
    }
    external = {
      version = "~> 2.0"
      source  = "hashicorp/external"
    }
    github = {
      version = "6.8.3"
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
