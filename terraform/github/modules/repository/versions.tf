terraform {
  required_version = "~> 1.0"
  required_providers {
    github = {
      version = "5.24.0"
      source  = "integrations/github"
    }
  }
}
